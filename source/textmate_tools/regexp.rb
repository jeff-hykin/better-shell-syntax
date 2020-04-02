require 'json'
require 'yaml'
require 'set'
require 'deep_clone' # gem install deep_clone
require 'pathname'

#
# extend Regexp to make expressions very readable
#
class Regexp
    attr_accessor :repository_name
    attr_accessor :has_top_level_group
    @@textmate_attributes = {
        name: "",
        match: "",
        patterns: "",
        comment: "",
        tag_as: "",
        includes: "",
        reference: "",
        should_fully_match: "",
        should_not_fully_match: "",
        should_partial_match: "",
        should_not_partial_match: "",
        repository: "",
        word_cannot_be_any_of: "",
        no_warn_match_after_newline?: "",
    }

    def __deep_clone__()
        # copy the regex
        self_as_string = self.without_default_mode_modifiers
        new_regex = /#{self_as_string}/
        # copy the attributes
        new_attributes = self.group_attributes.__deep_clone__
        new_regex.group_attributes = new_attributes
        new_regex.has_top_level_group = self.has_top_level_group
        return new_regex
    end

    def self.runTest(test_name, arguments, lambda, new_regex)
        if arguments[test_name] != nil
            if not( arguments[test_name].is_a?(Array) )
                raise "\n\nI think there's a #{test_name}: argument, for a newPattern or helper, but the argument isn't an array (and it needs to be to work)\nThe other arguments are #{arguments.to_yaml}"
            end
            failures = []
            for each in arguments[test_name]
                # suppress the regex warnings "nested repeat operator '?' and '+' was replaced with '*' in regular expression"
                suppress_output do
                    if lambda[each]
                        failures.push(each)
                    end
                end
            end
            if failures.size > 0
                puts "\n\nWhen testing the pattern:\nregex: #{new_regex.inspect}\n with these arguments:\n#{arguments.to_yaml}\n\nThe #{test_name} test failed for:\n#{failures.to_yaml}"
            end
        end
    end

    #
    # English Helpers
    #
    def lookAheadFor      (other_regex) processRegexLookarounds(other_regex, 'lookAheadFor'     ) end
    def lookAheadToAvoid  (other_regex) processRegexLookarounds(other_regex, 'lookAheadToAvoid' ) end
    def lookBehindFor     (other_regex) processRegexLookarounds(other_regex, 'lookBehindFor'    ) end
    def lookBehindToAvoid (other_regex) processRegexLookarounds(other_regex, 'lookBehindToAvoid') end
    def then         (*arguments) processRegexOperator(arguments, 'then'         ) end
    def or           (*arguments) processRegexOperator(arguments, 'or'           ) end
    def maybe        (*arguments) processRegexOperator(arguments, 'maybe'        ) end
    def oneOrMoreOf  (*arguments) processRegexOperator(arguments, 'oneOrMoreOf'  ) end
    def zeroOrMoreOf (*arguments) processRegexOperator(arguments, 'zeroOrMoreOf' ) end
    def matchResultOf(reference)
        #
        # generate the new regex
        #
        self_as_string = self.without_default_mode_modifiers
        other_regex_as_string = "[:backreference:#{reference}:]"
        new_regex = /#{self_as_string}#{other_regex_as_string}/

        #
        # carry over attributes
        #
        new_regex.group_attributes = self.group_attributes
        return new_regex
    end
    def reTag(arguments)
        keep_tags = !(arguments[:all] == false || arguments[:keep] == false) || arguments[:append] != nil

        pattern_copy = self.__deep_clone__
        new_attributes = pattern_copy.group_attributes

        # this is O(N*M) and could be expensive if reTagging a big pattern
        new_attributes.map!.with_index do |attribute, index|
            # preserves references
            if attribute[:tag_as] == nil
                attribute[:retagged] = true
                next attribute
            end
            arguments.each do |key, tag|
                if key == attribute[:tag_as] or key == attribute[:reference] or key == (index + 1).to_s
                    attribute[:tag_as] = tag
                    attribute[:retagged] = true
                end
            end
            if arguments[:append] != nil
                attribute[:tag_as] = attribute[:tag_as] + "." + arguments[:append]
            end
            next attribute
        end
        if not keep_tags
            new_attributes.each do |attribute|
                if attribute[:retagged] != true
                    attribute.delete(:tag_as)
                end
            end
        end
        new_attributes.each { |attribute| attribute.delete(:retagged) }
        return pattern_copy
    end
    def recursivelyMatch(reference)
        #
        # generate the new regex
        #
        self_as_string = self.without_default_mode_modifiers
        other_regex_as_string = "[:subroutine:#{reference}:]"
        new_regex = /#{self_as_string}#{other_regex_as_string}/

        #
        # carry over attributes
        #
        new_regex.group_attributes = self.group_attributes
        return new_regex
    end
    def to_tag(ignore_repository_entry: false, without_optimizations: false)
        if not ignore_repository_entry
            # if this pattern is in the repository, then just return a reference to the repository
            if self.repository_name != nil
                return { include: "##{self.repository_name}" }
            end
        end

        regex_as_string = self.without_default_mode_modifiers
        captures = self.captures
        output = {
            match: regex_as_string,
            captures: captures,
        }

        # if no regex in the pattern
        if regex_as_string == '()'
            puts "\n\nThere is a newPattern(), or one of its helpers, where no 'match' argument was given"
            puts "Here is the data for the pattern:"
            puts @group_attributes.to_yaml
            raise "Error: see printout above"
        end

        # check for matching after \n
        skip_newline_check = group_attributes.any? {|attribute| attribute[:no_warn_match_after_newline?]}
        if /\\n(.*?)(?:\||\\n|\]|$)/ =~ regex_as_string and not skip_newline_check
            if /[^\^$\[\]\(\)?:+*=!<>\\]/ =~ $1
                puts "\n\nThere is a pattern that likely tries to match characters after \\n\n"
                puts "textmate grammars only operate on a single line, \\n is the last possible character that can be matched.\n"
                puts "Here is the pattern:\n"
                puts regex_as_string
            end
        end
        group_attributes.delete(:no_warn_match_after_newline?)

        #
        # Top level pattern
        #
        # summary:
            # this if statement bascially converts this tag:
            # {
            #     match: '(oneThing)'
            #     captures: {
            #         '1' : {
            #             name: "thing.one"
            #         }
            #     }
            # }
            # into this tag:
            # {
            #     match: 'oneThing'
            #     name: "thing.one"
            # }
        if self.has_top_level_group && !without_optimizations
            #
            # remove the group from the regex
            #
            # safety check (should always be false unless some other code is broken)
            if not ( (regex_as_string.size > 1) and (regex_as_string[0] == '(') and (regex_as_string[-1] == ')') )
                raise "\n\nInside Regexp.to_tag, trying to upgrade a group-1 into a tag name, there doesn't seem to be a group one even though there are attributes\nThis is a library-developer bug as this should never happen.\nThe regex is #{self}\nThe groups are#{self.group_attributes}"
            end
            # remove the first and last ()'s
            output[:match] = regex_as_string[1...-1]
            was_first_group_removed = true
            #
            # update the capture groups
            #
            # decrement all of them by one (since the first one was removed)
            new_captures = {}
            for each_group_number, each_group in captures.each_pair
                decremented_by_1 = (each_group_number.to_i - 1).to_s
                new_captures[decremented_by_1] = each_group
            end
            zero_group = new_captures['0']
            # if name is the only value
            if zero_group.is_a?(Hash) && (zero_group[:name] != nil) && zero_group.keys.size == 1
                # remove the 0th capture group
                top_level_group = new_captures.delete('0')
                # add the name to the output
                output[:name] = Grammar.convertTagName(zero_group[:name], 0, @group_attributes, was_first_group_removed: was_first_group_removed)
            end
            output[:captures] = new_captures
        end

        # create real backreferences
        output[:match] = Grammar.fixupBackRefs(output[:match], @group_attributes, was_first_group_removed: was_first_group_removed)

        # convert all of the "$match" into their group numbers
        if output[:captures].is_a?(Hash)
            for each_group_number, each_group in output[:captures].each_pair
                if each_group[:name].is_a?(String)
                    output[:captures][each_group_number][:name] = Grammar.convertTagName(each_group[:name], each_group_number, @group_attributes, was_first_group_removed: was_first_group_removed)
                end
            end
        end

        # if captures dont exist then dont show them in the output
        if output[:captures] == {}
            output.delete(:captures)
        end

        return output
    end

    def captures
        captures = {}
        for group_number in 1..self.group_attributes.size
            raw_attributes = @group_attributes[group_number - 1]
            capture_group = {}

            # if no attributes then just skip
            if raw_attributes == {}
                next
            end

            # comments
            if raw_attributes[:comment] != nil
                capture_group[:comment] = raw_attributes[:comment]
            end

            # convert "tag_as" into the TextMate "name"
            if raw_attributes[:tag_as] != nil
                capture_group[:name] = raw_attributes[:tag_as]
            end

            # check for "includes" convert it to "patterns"
            if raw_attributes[:includes] != nil
                if not (raw_attributes[:includes].instance_of? Array)
                    raise "\n\nWhen converting a pattern into a tag (to_tag) there was a group that had an 'includes', but the includes wasn't an array\nThe pattern is:#{self}\nThe group attributes are: #{raw_attributes}"
                end
                # create the pattern list
                capture_group[:patterns] = Grammar.convertIncludesToPatternList(raw_attributes[:includes])
            end

            # check for "repository", run conversion on it
            if raw_attributes[:repository] != nil
                capture_group[:repository] = Grammar.convertRepository(raw_attributes[:repository])
            end

            # a check for :name, and :patterns and tell them to use tag_as and includes instead
            if raw_attributes[:name] or raw_attributes[:patterns]
                raise "\n\nSomewhere there is a name: or patterns: attribute being set (inside of a newPattern() or helper)\ninstead of name: please use tag_as:\ninstead of patterns: please use includes:\n\nThe arguments for the pattern are:\n#{raw_attributes.to_yaml}"
            end

            # check for unknown names
            attributes_copy = Marshal.load(Marshal.dump(raw_attributes))
            attributes_copy.delete_if { |k, v| @@textmate_attributes.key? k }
            if attributes_copy.size != 0
                raise "\n\nThere are arugments being given to a newPattern or a helper that are not understood\nThe unknown arguments are:\n#{attributes_copy}\n\nThe normal arguments are#{raw_attributes}"
            end

            # set the capture_group
            if capture_group != {}
                captures[group_number.to_s] = capture_group
            end
        end
        return captures
    end

    # convert it to a string and have it without the "(?-mix )" part
    def without_default_mode_modifiers()
        as_string = self.to_s
        # if it is the default settings (AKA -mix) then remove it
        if (as_string.size > 6) and (as_string[0..5] == '(?-mix')
            return self.inspect[1..-2]
        else
            return as_string
        end
    end

    # replace all of the () groups with (?:) groups
    # has the side effect of removing all comments
    def without_numbered_capture_groups
        # unescaped ('s can exist in character classes, and character class-style code can exist inside comments.
        # this removes the comments, then finds the character classes: escapes the ('s inside the character classes then
        # reverse the string so that varaible-length lookaheads can be used instead of fixed length lookbehinds
        as_string_reverse = self.without_default_mode_modifiers.reverse
        no_preceding_escape = /(?=(?:(?:\\\\)*)(?:[^\\]|\z))/
        reverse_character_class_match = /(\]#{no_preceding_escape}[\s\S]*?\[#{no_preceding_escape})/
        reverse_comment_match = /(\)#{no_preceding_escape}[^\)]*#\?\(#{no_preceding_escape})/
        reverse_start_paraenthese_match = /\(#{no_preceding_escape}/
        reverse_capture_group_start_paraenthese_match = /(?<!\?)\(#{no_preceding_escape}/

        reversed_but_fixed = as_string_reverse.gsub(/#{reverse_character_class_match}|#{reverse_comment_match}/) do |match_data, more_data|
            # if found a comment, just remove it
            if (match_data.size > 3) and  match_data[-3..-1] == '#?('
                ''
            # if found a character class, then escape any ()'s that are in it
            else
                match_data.gsub reverse_start_paraenthese_match, '\\('.reverse
            end
        end
        # make all capture groups non-capture groups
        reversed_but_fixed.gsub! reverse_capture_group_start_paraenthese_match, '(?:'.reverse
        return Regexp.new(reversed_but_fixed.reverse)
    end

    def getQuantifierFromAttributes(option_attributes)
        # by default assume no
        quantifier = ""
        #
        # Simplify the quantity down to just :at_least and :at_most
        #
            attributes_clone = option_attributes.clone
            # convert Enumerators to numbers
            for each in [:at_least, :at_most, :how_many_times?]
                if attributes_clone[each].is_a?(Enumerator)
                    attributes_clone[each] = attributes_clone[each].size
                end
            end
            # extract the data
            at_least       = attributes_clone[:at_least]
            at_most        = attributes_clone[:at_most]
            how_many_times = attributes_clone[:how_many_times?]
            # simplify to at_least and at_most
            if how_many_times.is_a?(Integer)
                at_least = at_most = how_many_times
            end
        #
        # Generate the ending based on :at_least and :at_most
        #
            # if there is no at_least, at_most, or how_many_times, then theres no quantifier
            if at_least == nil and at_most == nil
                quantifier = ""
            # if there is a quantifier
            else
                # if there's no at_least, then assume at_least = 1
                if at_least == nil
                    at_least = 1
                end
                # this is just a different way of "zeroOrMoreOf"
                if at_least == 0 and at_most == nil
                    quantifier = "*"
                # this is just a different way of "oneOrMoreOf"
                elsif at_least == 1 and at_most == nil
                    quantifier = "+"
                # if it is more complicated than that, just use a range
                else
                    quantifier = "{#{at_least},#{at_most}}"
                end
            end
        return quantifier
    end

    def self.checkForSingleEntity(regex)
        # unwrap the regex
        regex_as_string = regex.without_numbered_capture_groups.without_default_mode_modifiers
        debug =  (regex_as_string =~ /[\s\S]*\+[\s\S]*/) && regex_as_string.length < 10 && regex_as_string != "\\s+"
        # remove all escaped characters
        regex_as_string.gsub!(/\\./, "a")
        # remove any ()'s or ['s in the character classes, and replace them with "a"
        regex_as_string.gsub!(/\[[^\]]+\]/) do |match|
            clean_char_class = match[1..-2].gsub(/\[/, "a").gsub(/\(/,"a").gsub(/\)/, "a")
            match[0] + clean_char_class + match[-1]
        end

        # extract the ending quantifiers
        zero_or_more = /\*/
        one_or_more = /\+/
        maybe = /\?/
        range = /\{(?:\d+\,\d*|\d*,\d+|\d)\}/
        greedy = /\??/
        possessive = /\+?/
        quantifier = /(?:#{zero_or_more}|#{one_or_more}|#{maybe}|#{range})/
        quantified_ending_pattern = /#{quantifier}#{possessive}#{greedy}\Z/
        quantified_ending = ""
        regex_without_quantifier = regex_as_string.gsub(quantified_ending_pattern) do |match|
            quantified_ending = match
            "" # remove the ending
        end

        # regex without the ending
        main_group = regex.without_default_mode_modifiers
        # remove the quantified ending
        main_group = main_group[0..-(quantified_ending.length + 1)]

        entity = nil
        # if its a single character
        if regex_without_quantifier.length == 1
            entity = :single_char
        # if its a single escaped character
        elsif regex_without_quantifier.length == 2 && regex_without_quantifier[0] == "\\"
            entity = :single_escaped_char
        # if it has matching ()'s
        elsif checkForMatchingOuter(regex_without_quantifier, "(", ")")
            entity = :group
        # if it has matching []'s
        elsif checkForMatchingOuter(regex_without_quantifier, "[", "]")
            entity = :character_class
        end


        return [entity, quantified_ending, main_group]
    end

    def processRegexOperator(arguments, operator)
        # first parse the arguments
        other_regex, pattern_attributes = Regexp.processGrammarArguments(arguments, operator)
        if other_regex == nil
            other_regex = //
        end
        # pattern_attributes does not clone well, option_attributes must be the clone
        option_attributes = pattern_attributes.clone
        pattern_attributes.keep_if { |k, v| @@textmate_attributes.key? k }
        option_attributes.delete_if { |k, v| @@textmate_attributes.key? k }

        no_attributes = pattern_attributes == {}
        add_capture_group = ! no_attributes

        self_as_string = self.without_default_mode_modifiers
        other_regex_as_string = other_regex.without_default_mode_modifiers

        # handle :word_cannot_be_any_of
        if pattern_attributes[:word_cannot_be_any_of] != nil
            # add the boundary
            other_regex_as_string = /(?!\b(?:#{pattern_attributes[:word_cannot_be_any_of].join("|")})\b)#{other_regex_as_string}/
            # don't let the argument carry over to the next regex
            pattern_attributes.delete(:word_cannot_be_any_of)
        end

        # compute the endings so the operators can use/handle them
        simple_quantifier_ending = self.getQuantifierFromAttributes(option_attributes)

        # create a helper to handle common logic
        groupWrap = ->(regex_as_string) do
            # if there is a simple_quantifier_ending
            if simple_quantifier_ending.length > 0
                non_capture_group_is_needed = true
                #
                # perform optimizations
                #
                    single_entity_type, existing_ending, regex_without_quantifier  = Regexp.checkForSingleEntity(/#{regex_as_string}/)
                    # if there is a single entity
                    if single_entity_type != nil
                        # if there is only one
                        regex_as_string = regex_without_quantifier
                        # if adding an optional condition to a one-or-more, optimize it into a zero-or more
                        if existing_ending == "+" && simple_quantifier_ending == "?"
                            existing_ending = ""
                            simple_quantifier_ending = "*"
                        end
                    end
                #
                # Handle greedy/non-greedy endings
                #
                    if option_attributes[:quantity_preference] == :as_few_as_possible
                        # add the non-greedy quantifier
                        simple_quantifier_ending += "?"
                    # raise an error for an invalid option
                    elsif option_attributes[:quantity_preference] != nil && option_attributes[:quantity_preference] != :as_many_as_possible
                        raise "\n\nquantity_preference: #{option_attributes[:quantity_preference]}\nis an invalid value. Valid values are:\nnil, :as_few_as_possible, :as_many_as_possible"
                    end
                # if the group is not a single entity
                if single_entity_type == nil
                    # wrap the regex in a non-capture group, and then give it a quantity
                    regex_as_string = "(?:#{regex_as_string})"+simple_quantifier_ending
                # if the group is a single entity, then there is no need to wrap it
                else
                    regex_as_string = regex_as_string + simple_quantifier_ending
                end
            end
            # if backtracking isn't allowed, then wrap it in an atomic group
            if option_attributes[:dont_back_track?]
                regex_as_string = "(?>#{regex_as_string})"
            end
            # if it should be wrapped in a capture group, then add the capture group
            if add_capture_group
                regex_as_string = "(#{regex_as_string})"
            end
            regex_as_string
        end

        #
        # Set quantifiers
        #
        if ['maybe', 'oneOrMoreOf', 'zeroOrMoreOf'].include?(operator)
            # then don't allow manual quantification
            if simple_quantifier_ending.length > 0
                raise "\n\nSorry you can't use how_many_times?:, at_least:, or at_most with the #{operator}() function"
            end
            # set the quantifier (which will be applied inside of groupWrap[])
            case operator
                when 'maybe'
                    simple_quantifier_ending = "?"
                when 'oneOrMoreOf'
                    simple_quantifier_ending = "+"
                when 'zeroOrMoreOf'
                    simple_quantifier_ending = "*"
            end
        end
        #
        # Generate the core regex
        #
        if operator == 'or'
            new_regex = /(?:#{self_as_string}|#{groupWrap[other_regex_as_string]})/
        # if its any other operator (including the quantifiers)
        else
            new_regex = /#{self_as_string}#{groupWrap[other_regex_as_string]}/
        end

        #
        # Make changes to capture groups/attributes
        #
        # update the attributes of the new regex
        if no_attributes
            new_regex.group_attributes = self.group_attributes + other_regex.group_attributes
        else
            new_regex.group_attributes = self.group_attributes + [ pattern_attributes ] + other_regex.group_attributes
        end
        # if there are arributes, then those attributes are top-level
        if (self == //) and (pattern_attributes != {})
            new_regex.has_top_level_group = true
        end

        #
        # run tests
        #
        # temporarily implement matchResultOfs for tests
        test_regex = Grammar.fixupBackRefs(new_regex.without_default_mode_modifiers, new_regex.group_attributes, was_first_group_removed: false)
        # suppress the regex warnings "nested repeat operator '?' and '+' was replaced with '*' in regular expression"
        suppress_output do
            test_regex = Regexp.new(test_regex)
        end
        Regexp.runTest(:should_partial_match    , pattern_attributes, ->(each){       not (each =~ test_regex)       } , test_regex)
        Regexp.runTest(:should_not_partial_match, pattern_attributes, ->(each){      (each =~ test_regex) != nil     } , test_regex)
        Regexp.runTest(:should_fully_match      , pattern_attributes, ->(each){   not (each =~ /\A#{test_regex}\z/)  } , test_regex)
        Regexp.runTest(:should_not_fully_match  , pattern_attributes, ->(each){ (each =~ /\A#{test_regex}\z/) != nil } , test_regex)
        return new_regex
    end

    def processRegexLookarounds(other_regex, lookaround_name)
        # if it is an array, then join them as an or statement
        if other_regex.is_a?(Array)
            other_regex = Regexp.new("(?:#{Regexp.quote(other_regex.join("|"))})")
        end
        #
        # generate the new regex
        #
        self_as_string = self.without_default_mode_modifiers
        other_regex_as_string = other_regex.without_default_mode_modifiers
        case lookaround_name
            when 'lookAheadFor'      then new_regex = /#{self_as_string}(?=#{ other_regex_as_string})/
            when 'lookAheadToAvoid'  then new_regex = /#{self_as_string}(?!#{ other_regex_as_string})/
            when 'lookBehindFor'     then new_regex = /#{self_as_string}(?<=#{other_regex_as_string})/
            when 'lookBehindToAvoid' then new_regex = /#{self_as_string}(?<!#{other_regex_as_string})/
        end

        #
        # carry over attributes
        #
        new_regex.group_attributes = self.group_attributes
        return new_regex
    end

    # summary
    #     the 'under the hood' of this feels complicated, but the resulting behavior is simple
    #     (this is abstracted into a class-method because its used in many instance functions)
    #     basically just let the user give either 1. only a pattern, or 2. let them give a Hash that provides more details
    def self.processGrammarArguments(arguments, error_location)
        arg1 = arguments[0]
        # if only a pattern, set attributes to {}
        if arg1.instance_of? Regexp
            other_regex = arg1
            attributes = {}
        # if its a Hash then extract the regex, and use the rest of the hash as the attributes
        elsif arg1.instance_of? Hash
            other_regex = arg1[:match]
            attributes = arg1.clone
            attributes.delete(:match)
        else
            raise "\n\nWhen creating a pattern, there is a #{error_location}() that was called, but the argument was not a Regex pattern or a Hash.\nThe function doesn't know what to do with the arguments:\n#{arguments}"
        end
        return [ other_regex, attributes ]
    end

    #
    # getter/setter for group_attributes
    #
        def group_attributes=(value)
            @group_attributes = value
        end

        def group_attributes
            if @group_attributes == nil
                @group_attributes = []
            end
            return @group_attributes
        end
end

class Pattern < Regexp
    # overwrite the new pattern instead of initialize
    def self.new(*args)
        return //.then(*args)
    end
end

#
# Make safe failure for regex methods on strings
#
class String
    # make the without_default_mode_modifiers do nothing for strings
    def without_default_mode_modifiers()
        return self
    end
end
