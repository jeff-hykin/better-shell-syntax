require('yaml')

require_relative('suppress_output.rb')
require(PathFor[:error_helper])

# @param str [String]
# @param start_char [String]
# @param end_char [String]
# @return [Boolean]
def checkForMatchingOuter(str, start_char, end_char)
	# must start and end with correct chars
	if str.length > 2 && str[0] == start_char && str[-1] == end_char
		# remove the first and last character
		str = str.chars
		str.shift()
		str.pop()

		depth = 0

		for char in str
			# for every open brace, 1 closed brace is allowed
			if char == start_char
				depth += 1
			elsif char == end_char
				depth -= 1
			end

			# if theres a closed brace before an open brace, then the outer ones dont match
			return false if depth == -1
		end

		return true
	end

	false
end

# **Monkey Patch**<br>
# Extend Regexp to make expressions very readable.<br><br>
class Regexp
	# @return [String]
	attr_accessor :repository_name

	# @return [Boolean]
	attr_accessor :has_top_level_group

	attr_writer   :group_attributes

	# Getter for group_attributes
	# @return [Array<Hash>]
	def group_attributes
		@group_attributes ||= [] # Cool: Ruby has a defined-or compound assignment op like Perl, whereas JS merely has defined-or.
	end

	# Use a hash to quickly check if an attribute is valid.
	@@textmate_attributes = {
		name: nil,
		match: nil,
		patterns: nil,
		comment: nil,
		tag_as: nil,
		includes: nil,
		reference: nil,
		should_fully_match: nil,
		should_not_fully_match: nil,
		should_partial_match: nil,
		should_not_partial_match: nil,
		repository: nil,
		word_cannot_be_any_of: nil,
		no_warn_match_after_newline?: nil,
	}

	# @return [Regexp]
	def __deep_clone__
		# copy the regex
		self_as_string = without_default_mode_modifiers
		new_regex      = /#{self_as_string}/

		# copy the attributes
		new_regex.group_attributes    = group_attributes.__deep_clone__
		new_regex.has_top_level_group = has_top_level_group

		new_regex
	end

	# @param test_name [String]
	# @param arguments [Hash<Array>]
	# @param lambda [Proc]
	# @param new_regex [Regexp]
	# @return [void]
	def self.runTest(test_name, arguments, lambda, new_regex)
		return if arguments[test_name].nil?

		unless arguments[test_name].is_a?(Array)
			error(
				"I think there's an argument '#{test_name}' for a newPattern or helper, but the argument isn't an array (and it needs to be to work).",
				'The other arguments are:', nil, arguments.to_yaml
			)
		end

		failures = []

		# suppress the regex warnings "nested repeat operator '?' and '+' was replaced with '*' in regular expression"
		arguments[test_name].each { |arg| suppress_output { failures.push(arg) if lambda.call(arg) } }

		return if failures.empty?

		warning(
			'When testing the pattern:', "regex: #{new_regex}", 'with these arguments:', arguments.to_yaml,
			nil, "The '#{test_name}' test failed for:", nil, failures.to_yaml
		)
	end

	#
	# English Helpers
	#

	def lookAheadFor(other_regex)      processRegexLookarounds(other_regex, 'lookAheadFor')      end
	def lookAheadToAvoid(other_regex)  processRegexLookarounds(other_regex, 'lookAheadToAvoid')  end
	def lookBehindFor(other_regex)     processRegexLookarounds(other_regex, 'lookBehindFor')     end
	def lookBehindToAvoid(other_regex) processRegexLookarounds(other_regex, 'lookBehindToAvoid') end

	def then(*arguments)               processRegexOperator(arguments, 'then')         end
	def or(*arguments)                 processRegexOperator(arguments, 'or')           end
	def maybe(*arguments)              processRegexOperator(arguments, 'maybe')        end
	def oneOrMoreOf(*arguments)        processRegexOperator(arguments, 'oneOrMoreOf')  end
	def zeroOrMoreOf(*arguments)       processRegexOperator(arguments, 'zeroOrMoreOf') end

	# @param reference [String]
	def matchResultOf(reference)
		# generate the new regex
		self_as_string        = without_default_mode_modifiers
		other_regex_as_string = "[:backreference:#{reference}:]"
		new_regex             = /#{self_as_string}#{other_regex_as_string}/

		# carry over attributes
		new_regex.group_attributes = group_attributes

		new_regex
	end

	# @param arguments [Hash]
	def reTag(arguments)
		keep_tags = arguments[:all] != false && arguments[:keep] != false || !arguments[:append].nil?

		pattern_copy   = __deep_clone__
		new_attributes = pattern_copy.group_attributes

		# this is O(N*M) and could be expensive if reTagging a big pattern
		new_attributes.map!.with_index do |attribute, index|
			# preserves references
			if attribute[:tag_as].nil?
				attribute[:retagged] = true

				next attribute
			end

			arguments.each do |key, tag|
				if [attribute[:tag_as], attribute[:reference], (index + 1).to_s].include?(key)
					attribute[:tag_as] = tag
					attribute[:retagged] = true
				end
			end

			attribute[:tag_as] += '.' + arguments[:append] unless arguments[:append].nil?

			attribute
		end

		unless keep_tags
			new_attributes.each { |attribute| attribute.delete(:tag_as) unless attribute[:retagged] == true }
		end

		new_attributes.each { |attribute| attribute.delete(:retagged) }

		pattern_copy
	end

	# @param reference [String]
	def recursivelyMatch(reference)
		# generate the new regex
		self_as_string        = without_default_mode_modifiers
		other_regex_as_string = "[:subroutine:#{reference}:]"
		new_regex             = /#{self_as_string}#{other_regex_as_string}/

		# carry over attributes
		new_regex.group_attributes = group_attributes

		new_regex
	end

	# @param [Boolean] ignore_repository_entry
	# @param [Boolean] without_optimizations
	# @return [Hash]
	def to_tag(ignore_repository_entry: false, without_optimizations: false)
		unless ignore_repository_entry
			# if this pattern is in the repository, then just return a reference to the repository
			return { include: "##{repository_name}" } unless repository_name.nil?
		end

		regex_as_string = without_default_mode_modifiers
		captures        = self.captures

		output = {
			match: regex_as_string,
			captures: captures
		}

		# if no regex in the pattern
		if regex_as_string == '()'
			error(
				"There is a newPattern(), or one of its helpers, where no 'match' argument was given.",
				'Here is the data for the pattern:', @group_attributes.to_yaml
			)
		end

		# check for matching after \n

		skip_newline_check = group_attributes.any? { |attribute| attribute[:no_warn_match_after_newline?] }

		if /\\n(.*?)(?:\||\\n|\]|$)/ =~ regex_as_string && !skip_newline_check
			if /[^\^$\[\]\(\)?:+*=!<>\\]/ =~ $1
				warning(
					'There is a pattern that likely tries to match characters after \n.',
					'textmate grammars only operate on a single line, \n is the last possible character that can be matched.',
					'Here is the pattern:', regex_as_string
				)
			end
		end

		group_attributes.delete(:no_warn_match_after_newline?)

		# Top level pattern
		# summary:
		# this if statement bascially converts this tag:
		# {
		#	 match: '(oneThing)'
		#	 captures: {
		#		 '1' : {
		#			 name: "thing.one"
		#		 }
		#	 }
		# }
		# into this tag:
		# {
		#	 match: 'oneThing'
		#	 name: "thing.one"
		# }
		if has_top_level_group && !without_optimizations
			## remove the group from the regex

			# safety check (should always be false unless some other code is broken)
			unless !regex_as_string.empty? && regex_as_string[0] == '(' && regex_as_string[-1] == ')'
				error(
					'Inside Regexp.to_tag, trying to upgrade a group-1 into a tag name,',
					"there doesn't seem to be a group one even though there are attributes.",
					'This is a library developer bug as this should never happen.',
					"The regex is '#{self}',", "The groups are '#{group_attributes}'"
				)
			end

			# remove the first and last ()'s
			output[:match] = regex_as_string[1...-1]
			was_first_group_removed = true

			## update the capture groups

			new_captures = {}

			# decrement all of them by one (since the first one was removed)
			captures.each_pair { |group_number, group| new_captures[(group_number.to_i - 1).to_s] = group }

			zero_group = new_captures['0']

			if zero_group.is_a?(Hash) && !zero_group[:name].nil? && zero_group.keys.length == 1 # name is the only value
				# remove the 0th capture group
				new_captures.delete('0')

				# add the name to the output
				output[:name] = Grammar.convertTagName(zero_group[:name], 0, @group_attributes, was_first_group_removed: was_first_group_removed)
			end

			output[:captures] = new_captures
		end

		# create real backreferences
		output[:match] = Grammar.fixupBackRefs(output[:match], @group_attributes, was_first_group_removed: was_first_group_removed)

		# convert all of the "$match" into their group numbers
		if output[:captures].is_a?(Hash)
			output[:captures].each_pair do |group_number, group|
				output[:captures][group_number][:name] = Grammar.convertTagName(group[:name], group_number, @group_attributes, was_first_group_removed: was_first_group_removed) if group[:name].is_a?(String)
			end
		end

		# if captures don't exist then don't show them in the output
		output.delete(:captures) unless isNonEmptyHash(output[:captures])

		output
	end

	def captures
		captures = {}

		for group_number in 1..group_attributes.length
			# @type current_group_attributes [Hash]
			current_group_attributes = @group_attributes[group_number - 1]

			capture_group = {}

			# if no attributes then just skip
			next unless isNonEmptyHash(current_group_attributes)

			# comments
			capture_group[:comment] = current_group_attributes[:comment] unless current_group_attributes[:comment].nil?

			# convert "tag_as" into the TextMate "name"
			capture_group[:name] = current_group_attributes[:tag_as] unless current_group_attributes[:tag_as].nil?

			# check for "includes" convert it to "patterns"
			unless current_group_attributes[:includes].nil?
				unless current_group_attributes[:includes].is_a?(Array)
					error(
						"When converting a pattern into a tag, there was a group that had an 'includes',",
						"but the includes wasn't an array.", "The pattern is '#{self}',", "The group attributes are '#{current_group_attributes}'"
					)
				end

				# create the pattern list
				capture_group[:patterns] = Grammar.convertIncludesToPatternList(current_group_attributes[:includes])
			end

			# check for "repository", run conversion on it
			capture_group[:repository] = Grammar.convertRepository(current_group_attributes[:repository]) unless current_group_attributes[:repository].nil?

			# a check for :name, and :patterns and tell them to use tag_as and includes instead
			if current_group_attributes[:name] || current_group_attributes[:patterns]
				error(
					"Somewhere there is a 'name:' or 'patterns:' attribute being set (inside of a newPattern() or helper).", nil,
					"instead of 'name:' please use 'tag_as:',", "instead of 'patterns:' please use 'includes:'.", nil,
					'The arguments for the pattern are:', current_group_attributes.to_yaml
				)
			end

			## Check for unknown names

			# Not necessary to copy the referenced objects since they don't get deleted
			# or GC'ed when deleting the references from the copy, so a shallow copy suffices here.
			current_group_attributes_copy = current_group_attributes.clone

			current_group_attributes_copy.delete_if { |key| @@textmate_attributes.key?(key) }

			unless current_group_attributes_copy.empty?
				error(
					'There are arguments being given to a newPattern or a helper that are not understood.', nil,
					'The unknown arguments are:', current_group_attributes_copy, nil,
					'The normal arguments are:', current_group_attributes
				)
			end

			# set the capture_group
			captures[group_number.to_s] = capture_group unless capture_group.empty?
		end

		captures
	end

	# convert it to a string and have it without the "(?-mix )" part
	def without_default_mode_modifiers
		as_string = to_s

		# if it is the default settings (AKA -mix) then remove it
		if as_string.length > 6 && as_string[0..5] == '(?-mix'
			inspect[1..-2]
		else
			as_string
		end
	end

	# replace all of the () groups with (?:) groups
	# has the side effect of removing all comments
	def without_numbered_capture_groups
		# unescaped ('s can exist in character classes, and character class-style code can exist inside comments.
		# this removes the comments, then finds the character classes: escapes the ('s inside the character classes then
		# reverse the string so that varaible-length lookaheads can be used instead of fixed length lookbehinds.

		as_string_reverse                             = without_default_mode_modifiers.reverse
		no_preceding_escape                           = /(?=(?:(?:\\\\)*)(?:[^\\]|\z))/
		reverse_character_class_match                 = /(\]#{no_preceding_escape}[\s\S]*?\[#{no_preceding_escape})/
		reverse_comment_match                         = /(\)#{no_preceding_escape}[^\)]*#\?\(#{no_preceding_escape})/
		reverse_start_parenthese_match                = /\(#{no_preceding_escape}/
		reverse_capture_group_start_parenthese_match  = /(?<!\?)\(#{no_preceding_escape}/

		reversed_but_fixed = as_string_reverse.gsub(/#{reverse_character_class_match}|#{reverse_comment_match}/) do |match|
			if (match.length > 3) && match[-3..-1] == '#?(' # if found a comment, just remove it
				''
			else # if found a character class, then escape any ()'s that are in it
				match.gsub(reverse_start_parenthese_match, '\\('.reverse)
			end
		end

		# make all capture groups non-capture groups
		reversed_but_fixed.gsub!(reverse_capture_group_start_parenthese_match, '(?:'.reverse)

		Regexp.new(reversed_but_fixed.reverse)
	end

	def getQuantifierFromAttributes(option_attributes)
		## Simplify the quantity down to just :at_least and :at_most

		attributes_clone = option_attributes.clone

		# convert Enumerators to numbers
		for key in [:at_least, :at_most, :how_many_times?]
			attributes_clone[key] = attributes_clone[key].size if attributes_clone[key].is_a?(Enumerator)
		end

		# extract the data
		at_least	   = attributes_clone[:at_least]
		at_most		   = attributes_clone[:at_most]
		how_many_times = attributes_clone[:how_many_times?]

		# simplify to at_least and at_most
		at_least = at_most = how_many_times if how_many_times.is_a?(Integer)

		## Generate the ending based on :at_least and :at_most

		if at_least.nil? && at_most.nil? # if there is no at_least, at_most, or how_many_times, then there's no quantifier
			quantifier = ''
		else # there is a quantifier
			# if there's no at_least, then assume at_least = 1 # Why not 0? When omitting n in {n,m}, n is 0.
			at_least ||= 1

			quantifier =
				if at_least.zero? && at_most.nil? # this is just a different way of "zeroOrMoreOf"
					'*'
				elsif at_least == 1 && at_most.nil? # this is just a different way of "oneOrMoreOf"
					'+'
				else # if it is more complicated than that, just use a range
					"{#{at_least},#{at_most}}"
				end
		end

		quantifier
	end

	# @param regex [Regexp]
	# @return [Array(Symbol, String, String)]
	def self.checkForSingleEntity(regex)
		# unwrap the regex
		regex_as_string = regex.without_numbered_capture_groups.without_default_mode_modifiers

		# replace all escaped characters with "a"
		regex_as_string.gsub!(/\\./, 'a')

		# remove any ()'s or ['s in the character classes, and replace them with "a"
		regex_as_string.gsub!(/\[[^\]]+\]/) do |match|
			clean_char_class = match[1...-1].gsub(/\[/, 'a').gsub(/\(/, 'a').gsub(/\)/, 'a')
			match[0] + clean_char_class + match[-1]
		end

		# extract the ending quantifiers
		zero_or_more              = /\*/
		one_or_more               = /\+/
		maybe                     = /\?/
		range                     = /\{(?:\d+\,\d*|\d*,\d+|\d)\}/
		greedy                    = /\??/
		possessive                = /\+?/
		quantifier                = /(?:#{zero_or_more}|#{one_or_more}|#{maybe}|#{range})/
		quantified_ending_pattern = /#{quantifier}#{possessive}#{greedy}\Z/
		quantified_ending         = ''

		regex_without_quantifier = regex_as_string.gsub(quantified_ending_pattern) do |match|
			quantified_ending = match

			'' # remove the ending
		end

		# remove the quantified ending
		# Caution! One might be tempted to simplify the range to 0...-quantified_ending.length,
		# but this fails for quantified_ending.length == 0: s[0..-1] == s, but s[0...0] == ''.
		main_group = regex.without_default_mode_modifiers[0..-(quantified_ending.length + 1)]

		entity =
			if regex_without_quantifier.length == 1 # It's a single character
				:single_char
			elsif regex_without_quantifier.length == 2 && regex_without_quantifier[0] == '\\' # It's a single escaped character
				:single_escaped_char
			elsif checkForMatchingOuter(regex_without_quantifier, '(', ')') # It has matching ()'s
				:group
			elsif checkForMatchingOuter(regex_without_quantifier, '[', ']') # It has matching []'s
				:character_class
			end

		[entity, quantified_ending, main_group]
	end

	# @param arguments [Array]
	# @param operator [String]
	# @return [Regexp]
	def processRegexOperator(arguments, operator)
		# first parse the arguments
		other_regex, pattern_attributes = Regexp.processGrammarArguments(arguments, operator)

		other_regex ||= //

		# pattern_attributes does not clone well, option_attributes must be the clone
		option_attributes = pattern_attributes.clone
		pattern_attributes.keep_if { |key| @@textmate_attributes.key?(key) }
		option_attributes.delete_if { |key| @@textmate_attributes.key?(key) }

		no_attributes     = pattern_attributes.empty?
		add_capture_group = !no_attributes

		self_as_string        = without_default_mode_modifiers
		other_regex_as_string = other_regex.without_default_mode_modifiers

		# handle :word_cannot_be_any_of
		if pattern_attributes[:word_cannot_be_any_of]
			# add the boundary
			other_regex_as_string = /(?!\b(?:#{pattern_attributes[:word_cannot_be_any_of].join('|')})\b)#{other_regex_as_string}/

			# don't let the argument carry over to the next regex
			pattern_attributes.delete(:word_cannot_be_any_of)
		end

		# compute the endings so the operators can use/handle them
		simple_quantifier_ending = getQuantifierFromAttributes(option_attributes)

		# create a helper to handle common logic
		groupWrap = ->(regex_as_string) do
			# if there is a simple_quantifier_ending
			unless simple_quantifier_ending.empty?
				## perform optimizations

				single_entity_type, existing_ending, regex_without_quantifier = Regexp.checkForSingleEntity(/#{regex_as_string}/)

				unless single_entity_type.nil? # if there is a single entity
					regex_as_string = regex_without_quantifier

					# if adding an optional condition to a one-or-more, optimize it into a zero-or more
					simple_quantifier_ending = '*' if existing_ending == '+' && simple_quantifier_ending == '?'
				end

				## Handle greedy/non-greedy endings

				if option_attributes[:quantity_preference] == :as_few_as_possible # add the non-greedy quantifier
					simple_quantifier_ending += '?'
				elsif !option_attributes[:quantity_preference].nil? && option_attributes[:quantity_preference] != :as_many_as_possible # raise an error for an invalid option
					error(
						"quantity_preference '#{option_attributes[:quantity_preference]}' is an invalid value.",
						"Valid values are: 'nil', ':as_few_as_possible', ':as_many_as_possible'."
					)
				end

				# if the group is not a single entity
				regex_as_string =
					if single_entity_type.nil? # wrap the regex in a non-capture group, and then give it a quantity
						"(?:#{regex_as_string})"
					else # if the group is a single entity, then there is no need to wrap it
						regex_as_string
					end \
				+ simple_quantifier_ending
			end

			# if backtracking isn't allowed, then wrap it in an atomic group
			regex_as_string = "(?>#{regex_as_string})" if option_attributes[:dont_back_track?]

			# if it should be wrapped in a capture group, then add the capture group
			regex_as_string = "(#{regex_as_string})" if add_capture_group

			regex_as_string
		end

		## Set quantifiers

		if %w[maybe oneOrMoreOf zeroOrMoreOf].include?(operator) # then don't allow manual quantification
			error("Sorry, you can't use 'how_many_times?:', 'at_least:' or 'at_most:' with the #{operator}() function") unless simple_quantifier_ending.empty?

			# set the quantifier (which will be applied inside of groupWrap[])

			simple_quantifier_ending =
				case operator
					when 'maybe'        then '?'
					when 'oneOrMoreOf'  then '+'
					when 'zeroOrMoreOf' then '*'
				end
		end

		## Generate the core regex

		new_regex =
			if operator == 'or'
				/(?:#{self_as_string}|#{groupWrap.call(other_regex_as_string)})/
			else # Tt's any other operator (including the quantifiers)
				/#{self_as_string}#{groupWrap.call(other_regex_as_string)}/
			end

		## Make changes to capture groups/attributes

		# update the attributes of the new regex
		new_regex.group_attributes =
			if no_attributes
				group_attributes + other_regex.group_attributes
			else
				group_attributes + [pattern_attributes] + other_regex.group_attributes
			end

		# if there are attributes, then those attributes are top-level
		new_regex.has_top_level_group = self == // && !pattern_attributes.empty?

		## run tests

		# temporarily implement matchResultOfs for tests
		test_regex = Grammar.fixupBackRefs(new_regex.without_default_mode_modifiers, new_regex.group_attributes, was_first_group_removed: false)

		# suppress the regex warnings "nested repeat operator '?' and '+' was replaced with '*' in regular expression"
		suppress_output { test_regex = Regexp.new(test_regex) }

		Regexp.runTest(:should_partial_match, pattern_attributes, ->(arg) { arg !~ test_regex }, test_regex)
		Regexp.runTest(:should_not_partial_match, pattern_attributes, ->(arg) { arg =~ test_regex }, test_regex)
		Regexp.runTest(:should_fully_match, pattern_attributes, ->(arg) { arg !~ /\A#{test_regex}\z/ }, test_regex)
		Regexp.runTest(:should_not_fully_match, pattern_attributes, ->(arg) { arg =~ /\A#{test_regex}\z/ }, test_regex)

		new_regex
	end

	def processRegexLookarounds(other_regex, lookaround_name)
		# if it is an array, then join them as an or statement
		other_regex = Regexp.new("(?:#{Regexp.quote(other_regex.join('|'))})") if other_regex.is_a?(Array)

		# generate the new regex

		self_as_string = without_default_mode_modifiers
		other_regex_as_string = other_regex.without_default_mode_modifiers

		new_regex =
			case lookaround_name
				when 'lookAheadFor'	     then /#{self_as_string}(?=#{other_regex_as_string})/
				when 'lookAheadToAvoid'  then /#{self_as_string}(?!#{other_regex_as_string})/
				when 'lookBehindFor'     then /#{self_as_string}(?<=#{other_regex_as_string})/
				when 'lookBehindToAvoid' then /#{self_as_string}(?<!#{other_regex_as_string})/
			end

		# carry over attributes
		new_regex.group_attributes = group_attributes

		new_regex
	end

	# Summary<br>
	# the 'under the hood' of this feels complicated, but the resulting behavior is simple
	# (this is abstracted into a class-method because its used in many instance functions)
	# basically just let the user give either 1. only a pattern, or 2. let them give a Hash that provides more details
	# @param arguments [Array]
	# @param error_location [String]
	# @return [Array(Regexp, Hash)]
	def self.processGrammarArguments(arguments, error_location)
		arg1 = arguments[0]

		case arg1
			when Regexp # Pattern => set attributes to {}
				other_regex = arg1
				attributes  = {}
			when Hash # Extract the regex, and use the rest of the hash as the attributes
				other_regex = arg1[:match]
				attributes  = arg1.clone
				attributes.delete(:match)
			else
				error(
					"When creating a pattern, there is a #{error_location}() that was called, but the argument was not a Regex pattern or a Hash.",
					"The function doesn't know what to do with the arguments:", arguments
				)
		end

		[other_regex, attributes]
	end
end

class Pattern < Regexp
	# overwrite the new pattern instead of initialize
	def self.new(*args) //.then(*args) end
end

# **Monkey Patch**<br>
# Make safe failure for regex methods on strings.<br>
# Implements instance method `without_default_mode_modifiers`.<br><br>
class String
	# make the without_default_mode_modifiers do nothing for strings
	def without_default_mode_modifiers() self end
end

#
# Named patterns
#

@space                      = /\s/
@spaces                     = /\s+/
@digit                      = /\d/
@digits                     = /\d+/
@standard_character         = /\w/
@word                       = /\w+/
@word_boundary              = /\b/

@white_space_start_boundary = /(?<=\s)(?=\S)/
@white_space_end_boundary   = /(?<=\S)(?=\s)/
@start_of_document          = /\A/
@end_of_document            = /\Z/
@start_of_line              = /(?:^)/
@end_of_line                = /(?:\n|$)/

#
# Helper patterns
#

def newPattern(*arguments)        //.then(*arguments)              end
def lookAheadFor(*arguments)      //.lookAheadFor(*arguments)      end
def lookAheadToAvoid(*arguments)  //.lookAheadToAvoid(*arguments)  end
def lookBehindFor(*arguments)     //.lookBehindFor(*arguments)     end
def lookBehindToAvoid(*arguments) //.lookBehindToAvoid(*arguments) end
def maybe(*arguments)             //.maybe(*arguments)             end
def oneOrMoreOf(*arguments)       //.oneOrMoreOf(*arguments)       end
def zeroOrMoreOf(*arguments)      //.zeroOrMoreOf(*arguments)      end
def matchResultOf(reference)      //.matchResultOf(reference)      end
def recursivelyMatch(reference)   //.recursivelyMatch(reference)   end
def wordBounds(regex_pattern)     lookBehindToAvoid(@standard_character).then(regex_pattern).lookAheadToAvoid(@standard_character) end
