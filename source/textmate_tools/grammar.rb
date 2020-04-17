require('json')
require('yaml')
require('set')

require_relative('recursive_value_setting.rb')
require(PathFor[:error_helper])

class Grammar
	attr_accessor :data, :all_tags, :language_ending, :namespace, :export_options

	#
	# import and export methods
	#

	# This method's goal is to safely namespace external patterns.
	#
	# Usage:
	#
	#     Grammar.export(insert_namespace_infront_of_new_grammar_repos: true, insert_namespace_infront_of_all_included_repos: true) do |grammar, namespace|
	#         # create patterns here with the grammar object
	#     end
	#
	# However, there is no perfect way to get this done because of dynamic pattern generation and things like includes.<br>
	# Because the solution is imperfect, namespacing is opt-in with explicit names of the behavior<br>
	# namely,
	# - whether or not the `grammar[:repo_name]` will get namespaced
	# - and whether or not `Pattern(includes:[])` will get namespaced
	#
	# patterns are dynamically namespaced because it is caused by the grammar object they are being given access to
	# this can cause unintuitive results if you are accepting a repo name as an argument for a helper function because that repo name will
	# get dynamically namespaced. This is designed to be prevented by turning off the insert_namespace_infront_of_all_included_repos: option
	# @param args [Array]
	# @param insert_namespace_infront_of_new_grammar_repos [Boolean] Whether or not the `grammar[:repo_name]` will get namespaced
	# @param insert_namespace_infront_of_all_included_repos [Boolean] Whether or not `Pattern(includes:[])` will get namespaced
	# @return [void]
	def self.export(*args, &block)
		options = args.length == 1 ? args[0] : {}

		# this variable is used to pass data to the instance import() method
		@@export_data = {
			export_options: options,
			lambda: block,
		}
	end

	def import(filepath, namespace: '')
		unless File.absolute_path?(filepath)
			# try to detect the relative path
			source_directory = File.dirname(caller[0].sub(/:\d+:.+?$/, ''))

			# make the filepath absolute
			filepath = File.join(source_directory, filepath)
		end

		# make sure it has the .rb extension, for some reason it's required for the load function
		filepath += '.rb' if filepath[-3..-1] != '.rb'

		# import the file using load rather than require so that the @@export_data gets reset on each import
		load(filepath)

		# create a shallow copy of the grammar
		namespaced_grammar = Grammar.new(self, namespace, @@export_data[:export_options])

		# add the dot if needed
		send_namespace =
			if isNonEmptyString(namespace)
				namespace + '.'
			else
				''
			end

		unless @@export_data.nil?
			# run the import function with the namespaced grammar
			output = @@export_data[:lambda].call(namespaced_grammar, send_namespace)

			# clean up the consumed lambda
			@@export_data = nil
		end

		output
	end

	#
	# Class Methods
	#

	# @param name [String]
	# @param group_number [Integer]
	# @param group_attributes [Array<Hash>]
	# @param was_first_group_removed [Boolean]
	# @return [String]
	def self.convertTagName(name, group_number, group_attributes, was_first_group_removed: nil)
		new_name = name

		# replace $match with its group number
		new_name.gsub!(/(?<=\$)match/, group_number.to_s)

		# replace reference() with the group number it was referencing
		new_name.gsub!(/(?<=\$)reference\((\w+)\)/) do |match|
			reference      = match.match(/(?<=\()\w+/).to_s
			matching_index = group_attributes.find_index { |attribute| attribute[:reference] == reference }

			if matching_index.nil?
				error(
					"When looking for '#{match}', I couldn't find any groups with that reference.",
					'The groups are:', group_attributes.to_yaml
				)
			end

			if matching_index != group_attributes.length - 1 - group_attributes.rindex { |attribute| attribute[:reference] == reference }
				error(
					"When looking for '#{match}', I found multiple groups with that reference.",
					'The groups are:', group_attributes.to_yaml
				)
			end

			matching_index -= 1 if was_first_group_removed

			# the Nth matching_index is the (N+1)th capture group
			matching_index + 1
		end

		new_name
	end

	# replaces `[:backreference:reference]` with the groups number it was referencing
	# @param regex_as_string [String]
	# @param group_attributes [Array<Hash>]
	# @param was_first_group_removed [Boolean]
	# @return [String]
	def self.fixupBackRefs(regex_as_string, group_attributes, was_first_group_removed: nil)
		references = {}

		# convert all references to group numbers
		group_attributes.each.with_index { |attribute, index| references[attribute[:reference]] = index - (was_first_group_removed ? 1 : 0) + 1 if attribute[:reference] }

		# check for a backref to the Nth group, replace it with `\N` and try again
		regex_as_string.gsub!(/\[:backreference:([^\\]+?):\]/) do
			error("When processing the matchResultOf:#{$1}, I couldn't find the group it was referencing.") if references[$1].nil?

			"\\#{references[$1]}" # if the reference does exist, then replace it with its number
		end

		# check for a subroutine to the Nth group, replace it with `\N` and try again
		regex_as_string.gsub!(/\[:subroutine:([^\\]+?):\]/) do
			if references[$1].nil?
				# this is empty because the subroutine call is often built before the
				# thing it is referencing.
				# ex:
				# newPattern(
				#	 reference: "ref1",
				#	 match: newPattern(
				#		 /thing/.or(
				#			 recursivelyMatch("ref1")
				#		 )
				#	 )
				# )
				# there's no easy way to know if this is the case or not,
				# so by default nothing is returned so that problems are not caused
				''
			else
				"\\g<#{references[$1]}>" # if the reference does exist, then replace it with its number
			end
		end

		regex_as_string
	end

	# @param [String, Symbol, Regexp, PatternRange, Hash, Array] data
	# @param [Boolean] ignore_repository_entry
	# @return [Hash, String]
	def self.toTag(data, ignore_repository_entry: false)
		# This is clearly a case for 'case' ;)

		case data
			when String # Include it directly
				{ include: data }
			when Symbol # Include a # to make it a repository_name reference
				new_value =
					case data
						when :$initial_context
							'$initial_context'
						when :$base
							'$base'
						when :$self
							'$self'
						else
							"##{data}"
					end

				{ include: new_value }
			when Regexp, PatternRange # Convert it to a tag
				data.to_tag(ignore_repository_entry: ignore_repository_entry)
			when Hash # Just add it as-is
				data
			when Array
				{ patterns: Grammar.convertIncludesToPatternList(data) }
		end
	end

	# @param [Hash] repository
	# @return [Hash]
	def self.convertRepository(repository)
		return unless isNonEmptpyHash(repository)

		textmate_repository = {}

		repository.each_pair { |key, value| textmate_repository[key.to_s] = Grammar.toTag(value) }

		textmate_repository
	end

	# Summary:<br>
	# this takes a list, like:
	#
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
	#             includes: [:name_of_thing_in_repo] # <- this list also uses this convertIncludesToPatternList() function
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
	#
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
	# @param includes [Array<Symbol, Regexp, Hash>]
	# @param ignore_repository_entry [Boolean]
	# @return [Array<Hash>]
	def self.convertIncludesToPatternList(includes, ignore_repository_entry: false)
		return [] if includes.nil? # if input=nil then no patterns

		unless includes.is_a?(Array) # if input is not Array then error
			error(
				"When calling convertIncludesToPatternList(), the argument wasn't an array.",
				"The argument is '#{includes}'"
			)
		end

		# create the pattern list

		patterns = []

		includes.each { |include| patterns.push(Grammar.toTag(include, ignore_repository_entry: ignore_repository_entry)) }

		patterns
	end

	def self.convertSpecificIncludes(json_grammar: nil, convert: [], into: '')
		tags_to_convert = convert.map(&:to_s) # &:to_s = &:to_s.to_proc = { |obj| obj.to_s } (&proc = block; cf. def foo(&block) ... end where & does the opposite.)

		# iterate over all the keys
		json_grammar.recursively_set_each_value! do |value, key|
			if key.to_s == 'include'
				if tags_to_convert.include?(value.to_s) # if one of the tags matches
					into # then replace it with the new value
				else
					value
				end
			else
				value
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

			@namespace = isNonEmptyString(args[1]) ? args[1] : ''

			@export_options = kwargs
		else # if not making a copy then run the normal init
			init(*args, **kwargs)
		end
	end

	def init(wrap_source: false, name: nil, scope_name: nil, global_patterns: [], repository: {}, file_types: [], **other)
		@data = {
			name: name,
			scopeName: scope_name,
			fileTypes: file_types,
			**other,
			patterns: global_patterns,
			repository: repository,
		}

		@wrap_source     = wrap_source
		@language_ending = scope_name.gsub(/.+\.(.+)\z/, '\\1')
		@namespace       = ''
	end

	#
	# internal helpers
	#

	# @param key [Symbol]
	# @return [Symbol]
	def insertNamespaceIfNeeded(key)
		return (@namespace + '.' + key.to_s).to_sym if !@export_options.nil? && !@namespace.empty? && @export_options[:insert_namespace_infront_of_new_grammar_repos] == true

		key
	end

	# @param pattern [Regexp, PatternRange]
	# @return [void]
	def insertNamespaceToIncludesIfNeeded(pattern)
		return unless !@export_options.nil? && !@namespace.empty? && @export_options[:insert_namespace_infront_of_new_grammar_repos] == true
		# Always returns at this point.
		# What kind of object is supposed to have an 'includes' method?
		# Neither Regexp nor PatternRange have such a method.
		return unless pattern.respond_to?(:includes) && pattern.includes.is_a?(Array)

		# change all the repo names
		pattern.includes.clone.each_with_index do |include, index|
			pattern[index] = (@namespace + '.' + include.to_s).to_sym if include.is_a?(Symbol) # change the old value with a new one
		end
	end

	#
	# External Helpers
	#

	def [](*args)
		key = insertNamespaceIfNeeded(args[0])

		@data[:repository][key]
	end

	def []=(*args)
		# @type [Regexp, PatternRange, Hash, Array<Symbol, Regexp, PatternRange, Hash>]
		value = nil # Just to declare the possible types for Solargraph.

		# parse out the arguments: grammar[key, (overwrite_option)] = value
		*subscript_args, value = args
		key, overwrite_option  = subscript_args

		key = insertNamespaceIfNeeded(key)

		# check for accidental overwrite
		overwrite_allowed = overwrite_option&.values_at(:overwrite) == true

		unless @data[:repository][key].nil? || overwrite_allowed
			warning(
				"The '#{key}' repository is being overwritten.",
				'If this is intentional, change:', "grammar[:#{key}] = *value*", 'to:',
				"grammar[:#{key}, overwrite: true] = *value*")
		end

		# add it to the repository
		@data[:repository][key] = value

		return unless value.is_a?(Regexp) || value.is_a?(PatternRange)

		# TODO: if the value is an Array, run the insertNamespaceToIncludesIfNeeded

		# tell the object it was added to a repository
		value.repository_name = key

		# namespace all of the symbolic includes
		insertNamespaceToIncludesIfNeeded(value)
	end

	def addToRepository(hash_of_repos)
		@data[:repository].merge!(hash_of_repos)
	end

	# Couldn't find any references, seems unused.
	# What is each_pattern and each_key?
	def convertInitialContextReference(inherit_or_embedded)
		if @wrap_source
			each_pattern[each_key] = '#initial_context'
		elsif inherit_or_embedded == :inherit
			each_pattern[each_key] = '$base'
		elsif inherit_or_embedded == :embedded
			each_pattern[each_key] = '$self'
		else
			error("The 'inherit_or_embedded' needs to be either ':inherit' or ':embedded', but it was '#{inherit_or_embedded}' instead.")
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

		# @type [Hash]
		repository_copy = @data[:repository].dup

		#
		# Convert the :$initial_context into the patterns section
		#

		# @type [Array]
		initial_context = repository_copy.delete(:$initial_context)

		if @wrap_source
			repository_copy[:initial_context] = initial_context

			# make the actual "initial_context" be the source pattern
			textmate_output[:patterns] = Grammar.convertIncludesToPatternList([
				# this is the source pattern that always gets matched first
				PatternRange.new(
					zeroLengthStart?: true,
					# the first position
					start_pattern: lookAheadFor(/^|\A|\G/),
					# ensure end never matches
					# why? because textmate will keep looking until it hits the end of the file (which is the purpose of this wrapper)
					# how? because the regex is trying to find "not" and then checks to see if "not" == "possible" (which can never happen)
					end_pattern: /not/.lookBehindFor(/possible/),
					tag_as: 'source',
					includes: [:initial_context]
				)
			])
		else
			textmate_output[:patterns] = Grammar.convertIncludesToPatternList(initial_context)
		end

		for init_ctx_element in initial_context
			next unless init_ctx_element.is_a?(Symbol)

			error("In :$initial_context there's a '#{init_ctx_element}' but '#{init_ctx_element}' isn't actually a repo.") if self[init_ctx_element].nil?
		end

		#
		# Convert all the repository entries
		#

		repository_copy.each_key { |key| repository_copy[key] = Grammar.toTag(repository_copy[key], ignore_repository_entry: true).dup }

		textmate_output[:repository] = repository_copy

		#
		# Add the language endings
		#

		@all_tags = Set.new

		# convert all keys into strings
		textmate_output = JSON.parse(textmate_output.to_json)
		language_name   = textmate_output['name']
		textmate_output.delete('name')

		# convert all the language_endings
		textmate_output.recursively_set_each_value! do |value, key|
			if key == 'include'
				#
				# convert the $initial_context
				#

				if value == '$initial_context'
					if @wrap_source
						'#initial_context'
					elsif inherit_or_embedded == :inherit
						'$base'
					elsif inherit_or_embedded == :embedded
						'$self'
					else
						error("The 'inherit_or_embedded' needs to be either ':inherit' or ':embedded', but it was '#{inherit_or_embedded}' instead.")
					end
				else
					value
				end
			elsif %w[name contentName].include?(key) # %w[] is Ruby's equivalent to Perl's qw(), except that the former creates an Array, while the latter creates a list.
				#
				# add the language endings
				#

				new_names = []

				for tag in value.split(/\s/)
					tag_with_ending = tag

					# if it doesnt already have the ending then add it
					tag_with_ending += ".#{@language_ending}" unless tag_with_ending =~ /#{@language_ending}\z/

					new_names << tag_with_ending
					@all_tags.add(tag_with_ending)
				end

				new_names.join(' ')
			else
				value
			end
		end

		textmate_output['name'] = language_name

		textmate_output
	end

	def saveAsJsonTo(file_location, inherit_or_embedded: :embedded)
		new_file = File.open(file_location + '.json', 'w')
		new_file.write(JSON.pretty_generate(to_h(inherit_or_embedded: inherit_or_embedded)))
		new_file.close
	end

	def saveAsYamlTo(file_location, inherit_or_embedded: :embedded)
		new_file = File.open(file_location + '.yaml', 'w')
		new_file.write(to_h(inherit_or_embedded: inherit_or_embedded).to_yaml)
		new_file.close
	end

	def saveTagsTo(file_location)
		to_h(inherit_or_embedded: :embedded)
		new_file = File.open(file_location, 'w')
		new_file.write(@all_tags.to_a.sort.join("\n"))
		new_file.close
	end
end
