require 'json'
require 'yaml'
require 'set'
require 'deep_clone' # gem install deep_clone
require 'pathname'

class Grammar
    attr_accessor :data, :all_tags, :language_ending, :namespace, :export_options

    #
    # import and export methods
    #
    @@export_data
    def self.export(*args, &block)
        # this method's goal is to safely namespace external patterns
        # usage:
        #     Grammar.export(insert_namespace_infront_of_new_grammar_repos: true, insert_namespace_infront_of_all_included_repos: true) do |grammar, namespace|
        #         # create patterns here with the grammar object
        #     end
        #
        # however there is no perfect way to get this done because of dynamic pattern generation and things like includes
        # because the solution is imperfect, namespacing is opt-in with explicit names of the behavior
        # namely,
        # - whether or not the grammar[:repo_name] will get namespaced
        # - and whether or not Pattern(includes:[]) will get namespaced
        # patterns are dynamically namespaced because it is caused by the grammar object they are being given access to
        # this can cause unintuitive results if you are accepting a repo name as an argument for a helper function because that repo name will
        # get dynamically namespaced. This is designed to be prevented by turning off the insert_namespace_infront_of_all_included_repos: option
        options = {}
        if args.size == 1
            options = args[0]
        end
        # this variable is used to pass data to the instance import() method
        @@export_data = {
            export_options: options,
            lambda: block,
        }
    end

    def import(filepath, namespace:"")
        if not Pathname.new(filepath).absolute?
            # try to detect the relative path
            source_directory = File.dirname(caller[0].sub(/:\d+:.+?$/,""))
            # make the filepath absolute
            filepath = File.join(source_directory, filepath)
        end
        # make sure it has the .rb extension, for some reason its required for the load function
        if filepath[-3..-1] != ".rb"
            filepath += ".rb"
        end
        # import the file using load rather than require so that the @@export_data gets reset on each import
        load(filepath)
        # create a shallow copy of the grammar
        namespaced_grammar = Grammar.new(self, namespace, @@export_data[:export_options])
        # add the dot if needed
        if namespace.is_a?(String) && namespace.size > 0
            send_namespace = namespace + '.'
        else
            send_namespace = ''
        end
        if @@export_data != nil
            # run the import function with the namespaced grammar
            output = @@export_data[:lambda][namespaced_grammar, send_namespace]
            # clean up the consumed lambda
            @@export_data = nil
        end
        return output
    end

    #
    # Class Methods
    #
    def self.convertTagName(name, group_number, group_attributes, was_first_group_removed: nil)
        new_name = name
        # replace $match with its group number
        new_name.gsub!(/(?<=\$)match/,"#{group_number}" )
        # replace reference() with the group number it was referencing
        new_name.gsub! /(?<=\$)reference\((\w+)\)/ do |match|
            reference = match.match(/(?<=\()\w+/).to_s
            matching_index = group_attributes.find_index { |each| each[:reference] == reference }

            if matching_index == nil
                raise "\n\nWhen looking for #{match} I couldnt find any groups with that reference\nThe groups are:\n#{group_attributes.to_yaml}\n\n"
            elsif matching_index !=  group_attributes.size - 1 - group_attributes.reverse.find_index { |each| each[:reference] == reference }
                raise "\n\nWhen looking for #{match} I found multiple groups with that reference\nThe groups are:\n#{group_attributes.to_yaml}\n\n"
            end

            if was_first_group_removed
                matching_index -= 1
            end
            # the Nth matching_index is the (N+1)th capture group
            matching_index + 1
        end

        return new_name
    end
    # replaces [:backreference:reference] with the groups number it was referencing
    def self.fixupBackRefs(regex_as_string, group_attribute, was_first_group_removed: nil)
        references = Hash.new
        #convert all references to group numbers
        group_attribute.each.with_index { |each, index|
            if each[:reference]
                references[each[:reference]] = index - (was_first_group_removed ? 1 : 0) + 1
            end
        }
        # check for a backref to the Nth group, replace it with `\N` and try again
        regex_as_string.gsub! /\[:backreference:([^\\]+?):\]/ do |match|
            if references[$1] == nil
                raise "When processing the matchResultOf:#{$1}, I couldn't find the group it was referencing"
            end
            # if the reference does exist, then replace it with it's number
            "\\#{references[$1]}"
        end
        # check for a subroutine to the Nth group, replace it with `\N` and try again
        regex_as_string.gsub! /\[:subroutine:([^\\]+?):\]/ do |match|
            if references[$1] == nil
                # this is empty because the subroutine call is often built before the
                # thing it is referencing.
                # ex:
                # newPattern(
                #     reference: "ref1",
                #     match: newPattern(
                #         /thing/.or(
                #             recursivelyMatch("ref1")
                #         )
                #     )
                # )
                # there's no way easy way to know if this is the case or not
                # so by default nothing is returned so that problems are not caused
                ""
            else
                # if the reference does exist, then replace it with it's number
                "\\g<#{references[$1]}>"
            end
        end
        return regex_as_string
    end

    def self.toTag(data, ignore_repository_entry: false)
        # if its a string then include it directly
        if (data.instance_of? String)
            return { include: data }
        # if its a symbol then include a # to make it a repository_name reference
        elsif (data.instance_of? Symbol)
            if data == :$initial_context
                new_value = '$initial_context'
            elsif data == :$base
                new_value = '$base'
            elsif data == :$self
                new_value = '$self'
            else
                new_value = "##{data}"
            end
            return { include: new_value }
        # if its a pattern, then convert it to a tag
        elsif (data.instance_of? Regexp) or (data.instance_of? PatternRange)
            return data.to_tag(ignore_repository_entry: ignore_repository_entry)
        # if its a hash, then just add it as-is
        elsif (data.instance_of? Hash)
            return data
        elsif (data.instance_of? Array)
            return {
                patterns: Grammar.convertIncludesToPatternList(data)
            }
        end
    end

    def self.convertRepository(repository)
        if (repository.is_a? Hash) && (repository != {})
            textmate_repository = {}
            for each_key, each_value in repository.each_pair
                textmate_repository[each_key.to_s] = Grammar.toTag(each_value)
            end
            return textmate_repository
        end
    end

    def self.convertIncludesToPatternList(includes, ignore_repository_entry: false)
        # Summary:
            # this takes a list, like:
            #     [
            #         # symbol thats the name of a repo
            #         :name_of_thing_in_repo,
            #         # and/or OOP grammar patterns
            #         newPattern(
            #             match: /thing/,
            #             tag_as: 'a.tag.name'
            #         ),
            #         # and/or ranges
            #         PatternRange.new(
            #             start_pattern: /thing/,
            #             end_pattern: /endThing/,
            #             includes: [ :name_of_thing_in_repo ] # <- this list also uses this convertIncludesToPatternList() function
            #         ),
            #         # and/or hashes (hashes need to match the TextMate grammar JSON format)
            #         {
            #             match: /some_regex/,
            #             name: "some.tag.name"
            #         },
            #         # another example of the TextMate grammar format
            #         {
            #             include: '#name_of_thing_in_repo'
            #         }
            #     ]
            # then it converts that list into a TextMate grammar format like this:
            #     [
            #         # symbol conversion
            #         {
            #             include: '#name_of_thing_in_repo'
            #         },
            #         # pattern conversion
            #         {
            #             match: /thing/,
            #             name: 'a.tag.name'
            #         },
            #         # PatternRange conversion
            #         {
            #             begin: /thing/,
            #             end: /thing/,
            #             patterns: [
            #                 {
            #                     include: '#name_of_thing_in_repo'
            #                 }
            #             ]
            #         },
            #         # keeps TextMate hashes the same
            #         {
            #             match: /some_regex/,
            #             name: "some.tag.name"
            #         },
            #         # another example of the TextMate grammar format
            #         {
            #             include: '#name_of_thing_in_repo'
            #         }
            #     ]

        # if input=nil then no patterns
        if includes == nil
            return []
        end
        # if input is not Array then error
        if not (includes.instance_of? Array)
            raise "\n\nWhen calling convertIncludesToPatternList() the argument wasn't an array\nThe argument is:#{includes}"
        end
        # create the pattern list
        patterns = []
        for each_include in includes
            patterns.push(Grammar.toTag(each_include, ignore_repository_entry: ignore_repository_entry))
        end
        return patterns
    end

    def self.convertSpecificIncludes(json_grammar:nil, convert:[], into:"")
        tags_to_convert = convert.map{|each| each.to_s}
        # iterate over all the keys
        json_grammar.recursively_set_each_value! ->(each_value, each_key) do
            if each_key.to_s == "include"
                # if one of the tags matches
                if tags_to_convert.include?(each_value.to_s)
                    # then replace it with the new value
                    into
                else
                    each_value
                end
            else
                each_value
            end
        end
    end

    #
    # Constructor
    #
    def initialize(*args, **kwargs)
        # find out if making a grammar copy or not (for importing)
        if args[0].is_a?(Grammar)
            # make a shallow copy
            @data            = args[0].data
            @language_ending = args[0].language_ending
            if args[1].is_a?(String) && args[1].size > 0
                @namespace = args[1]
            else+
                @namespace = ""
            end
            @export_options  = kwargs
        # if not making a copy then run the normal init
        else
            self.init(*args, **kwargs)
        end
    end

    def init(wrap_source: false, name:nil, scope_name:nil, global_patterns:[], repository:{}, file_types:[], **other)
        @data = {
            name: name,
            scopeName: scope_name,
            fileTypes: file_types,
            **other,
            patterns: global_patterns,
            repository: repository,
        }
        @wrap_source     = wrap_source
        @language_ending = scope_name.gsub /.+\.(.+)\z/, "\\1"
        @namespace       = ""
    end

    #
    # internal helpers
    #
    def insertNamespaceIfNeeded(key)
        if @export_options != nil && @namespace.size > 0 && @export_options[:insert_namespace_infront_of_new_grammar_repos] == true
            return (@namespace + "." + key.to_s).to_sym
        end
        return key
    end

    def insertNamespaceToIncludesIfNeeded(pattern)
        if @export_options != nil && @namespace.size > 0 && @export_options[:insert_namespace_infront_of_new_grammar_repos] == true
            if pattern.respond_to?(:includes) && pattern.includes.is_a?(Array)
                # change all the repo names
                index = -1
                for each in pattern.includes.clone
                    index += 1
                    if each.is_a?(Symbol)
                        # change the old value with a new one
                        pattern[index] = (@namespace + "." + each.to_s).to_sym
                    end
                end
            end
        end
    end

    #
    # External Helpers
    #
    def [](*args)
        key = args[0]
        key = self.insertNamespaceIfNeeded(key)
        return @data[:repository][key]
    end

    def []=(*args)
        # parse out the arguments: grammar[key, (optional_overwrite)] = value
        *keys, value = args
        key, overwrite_option = keys
        key = self.insertNamespaceIfNeeded(key)
        # check for accidental overwrite
        overwrite_allowed = overwrite_option.is_a?(Hash) && overwrite_option[:overwrite]
        if @data[:repository][key] != nil && (not overwrite_option)
            puts "\n\nWarning: the #{key} repository is being overwritten.\n\nIf this is intentional, change:\ngrammar[:#{key}] = *value*\ninto:\ngrammar[:#{key}, overwrite: true] = *value*"
        end
        # add it to the repository
        @data[:repository][key] = value
        # TODO: if the value is an Array, run the insertNamespaceToIncludesIfNeeded
        # tell the object it was added to a repository
        if (value.instance_of? Regexp) || (value.instance_of? PatternRange)
            value.repository_name = key
            # namespace all of the symbolic includes
            self.insertNamespaceToIncludesIfNeeded(value)
        end
    end

    def addToRepository(hash_of_repos)
        @data[:repository].merge!(hash_of_repos)
    end

    def convertInitialContextReference(inherit_or_embedded)
        if @wrap_source
            each_pattern[each_key] = '#initial_context'
        elsif inherit_or_embedded == :inherit
            each_pattern[each_key] = "$base"
        elsif inherit_or_embedded == :embedded
            each_pattern[each_key] = "$self"
        else
            raise "\n\nError: the inherit_or_embedded needs to be either :inherit or embedded, but it was #{inherit_or_embedded} instead"
        end
    end

    def to_h(inherit_or_embedded: :embedded)
        #
        # initialize output
        #
        textmate_output = {
            **@data,
            patterns: [],
            repository: [],
        }
        repository_copy = @data[:repository].dup

        #
        # Convert the :$initial_context into the patterns section
        #
        initial_context = repository_copy[:$initial_context]
        repository_copy.delete(:$initial_context)
        if @wrap_source
            repository_copy[:initial_context] = initial_context
            # make the actual "initial_context" be the source pattern
            textmate_output[:patterns] = Grammar.convertIncludesToPatternList [
                # this is the source pattern that always gets matched first
                PatternRange.new(
                    zeroLengthStart?: true,
                    # the first position
                    start_pattern: lookAheadFor(/^|\A|\G/),
                    # ensure end never matches
                    # why? because textmate will keep looking until it hits the end of the file (which is the purpose of this wrapper)
                    # how? because the regex is trying to find "not" and then checks to see if "not" == "possible" (which can never happen)
                    end_pattern: /not/.lookBehindFor(/possible/),
                    tag_as: "source",
                    includes: [
                        :initial_context
                    ],
                )
            ]
        else
            textmate_output[:patterns] = Grammar.convertIncludesToPatternList(initial_context)
        end
        for each in initial_context
            if each.is_a? Symbol
                if self[each] == nil
                    raise "\n\nIn :$initial_context there's a \"#{each}\" but \"#{each}\" isn't actually a repo."
                end
            end
        end

        #
        # Convert all the repository entries
        #
        for each_name in repository_copy.keys
            repository_copy[each_name] = Grammar.toTag(repository_copy[each_name], ignore_repository_entry: true).dup
        end
        textmate_output[:repository] = repository_copy

        #
        # Add the language endings
        #
        @all_tags = Set.new()
        # convert all keys into strings
        textmate_output = JSON.parse(textmate_output.to_json)
        language_name = textmate_output["name"]
        textmate_output.delete("name")
        # convert all the language_endings
        textmate_output.recursively_set_each_value! ->(each_value, each_key) do
            if each_key == "include"
                #
                # convert the $initial_context
                #
                if each_value == "$initial_context"
                    if @wrap_source
                        '#initial_context'
                    elsif inherit_or_embedded == :inherit
                        "$base"
                    elsif inherit_or_embedded == :embedded
                        "$self"
                    else
                        raise "\n\nError: the inherit_or_embedded needs to be either :inherit or embedded, but it was #{inherit_or_embedded} instead"
                    end
                else
                    each_value
                end
            elsif each_key == "name" || each_key == "contentName"
                #
                # add the language endings
                #
                new_names = []
                for each_tag in each_value.split(/\s/)
                    each_with_ending = each_tag
                    # if it doesnt already have the ending then add it
                    if not (each_with_ending =~ /#{@language_ending}\z/)
                        each_with_ending += ".#{@language_ending}"
                    end
                    new_names << each_with_ending
                    @all_tags.add(each_with_ending)
                end
                new_names.join(' ')
            else
                each_value
            end
        end
        textmate_output["name"] = language_name
        return textmate_output
    end

    def saveAsJsonTo(file_location, inherit_or_embedded: :embedded)
        new_file = File.open(file_location+".json", "w")
        new_file.write(JSON.pretty_generate(self.to_h(inherit_or_embedded: inherit_or_embedded)))
        new_file.close
    end

    def saveAsYamlTo(file_location, inherit_or_embedded: :embedded)
        new_file = File.open(file_location+".yaml", "w")
        new_file.write(self.to_h(inherit_or_embedded: inherit_or_embedded).to_yaml)
        new_file.close
    end

    def saveTagsTo(file_location)
        self.to_h(inherit_or_embedded: :embedded)
        new_file = File.open(file_location, "w")
        new_file.write(@all_tags.to_a.sort.join("\n"))
        new_file.close
    end
end
