require('deep_clone') # See Gemfile. Ignore the warning, it works.

require_relative('suppress_output.rb')

class PatternRange
	# @return [Hash]
	attr_accessor :as_tag
	# @return [String]
	attr_accessor :repository_name
	# @return [Hash]
	attr_accessor :arguments

	def __deep_clone__
		PatternRange.new(@arguments.__deep_clone__)
	end

	# @param arguments [Hash]\
	#   Valid keys
	#     - comment: (idk why youd ever use this, but it exists for backwards compatibility)
	#     - tag_as:
	#     - tag_content_as:
	#     - apply_end_pattern_last:
	#     - while:
	#     - start_pattern:
	#     - end_pattern:
	#     - includes:
	#     - repository:
	#     - repository_name:
	def initialize(arguments)
		# save all of the arguments for later
		@arguments = arguments

		# generate the tag so that errors show up
		generateTag()
	end

	def generateTag
		# generate a tag version
		@as_tag = {}
		key_arguments = @arguments.clone

		# comment, tag_as, tag_content_as
		{ comment: :comment, tag_as: :name, tag_content_as: :contentName }.each_pair do |keySrc, keyDest|
			value = key_arguments.delete(keySrc)
			@as_tag[keyDest] = value if isNonEmptyString(value)
		end

		# apply_end_pattern_last
		apply_end_pattern_last = key_arguments.delete(:apply_end_pattern_last)
		@as_tag[:applyEndPatternLast] = apply_end_pattern_last if [true, 1].include?(apply_end_pattern_last)

		# while
		while_statement = key_arguments.delete(:while)

		if isNonEmptyRegexp(while_statement)
			@as_tag[:while]         = while_statement
			while_pattern_as_tag    = while_statement.to_tag(without_optimizations: true)
			while_captures          = while_pattern_as_tag[:captures]
			@as_tag[:whileCaptures] = while_captures if isNonEmptyHash(while_captures)
		end

		## start_pattern

		# @type [Regexp]
		start_pattern = key_arguments[:start_pattern]

		unless isNonEmptyRegexp(start_pattern)
			error(
				'The start pattern for a PatternRange needs to be a non-empty regular expression',
				'The PatternRange causing the problem is:', key_arguments
			)
		end

		key_arguments.delete(:start_pattern)

		start_pattern_as_tag = start_pattern.to_tag(without_optimizations: true)

		# prevent accidental zero length matches
		pattern = nil

		# suppress the regex warnings "nested repeat operator '?' and '+' was replaced with '*' in regular expression"
		suppress_output { pattern = /#{start_pattern_as_tag[:match]}/ }

		if '' =~ pattern && !key_arguments.delete(:zeroLengthStart?) && pattern.inspect != "/\G/"
			warning("'#{/#{start_pattern_as_tag[:match]}/.inspect}'", 'matches the zero length string ("").',
				'This means that the patternRange always matches.',
				'You can disable this warning by settting :zeroLengthStart? to true.',
				"The tag for this PatternRange is '#{@as_tag[:name]}")
		end

		@as_tag[:begin]         = start_pattern_as_tag[:match]
		begin_captures          = start_pattern_as_tag[:captures]
		@as_tag[:beginCaptures] = begin_captures if isNonEmptyHash(begin_captures)

		## end_pattern

		# @type [Regexp]
		end_pattern = key_arguments[:end_pattern]

		if @as_tag[:while].nil? && !isNonEmptyRegexp(end_pattern)
			error(
				'The end pattern for a PatternRange needs to be a non-empty regular expression',
				'The PatternRange causing the problem is:', key_arguments
			)
		end

		unless end_pattern.nil?
			key_arguments.delete(:end_pattern)

			end_pattern_as_tag = end_pattern.to_tag(without_optimizations: true, ignore_repository_entry: true)

			@as_tag[:end]         = end_pattern_as_tag[:match]
			end_captures          = end_pattern_as_tag[:captures]
			@as_tag[:endCaptures] = end_captures if isNonEmptyHash(end_captures)
		end

		## includes

		patterns = Grammar.convertIncludesToPatternList(key_arguments.delete(:includes))

		@as_tag[:patterns] = patterns unless patterns.empty?

		## repository

		repository = key_arguments.delete(:repository)

		@as_tag[:repository] = Grammar.convertRepository(repository) if isNonEmptyHash(repository)

		# key_arguments should be empty at this point.
		error('Unknown arguments given to the constructor:', *key_arguments.map { |arg, value| "Argument: #{arg}, value: #{value}" }) unless key_arguments.empty?
	end

	def to_tag(ignore_repository_entry: false)
		# if it hasn't been generated somehow, then generate it
		generateTag() if @as_tag.nil?

		return @as_tag if ignore_repository_entry

		return { include: "##{@repository_name}" } unless @repository_name.nil?

		@as_tag
	end

	# @param arguments [Hash]
	# @return [PatternRange]
	def reTag(arguments)
		# create a copy
		the_copy = __deep_clone__()

		# reTag the patterns
		the_copy.arguments[:start_pattern] = the_copy.arguments[:start_pattern].reTag(arguments)
		the_copy.arguments[:end_pattern]   = the_copy.arguments[:end_pattern].reTag(arguments) unless the_copy.arguments[:end_pattern].nil?
		the_copy.arguments[:while]         = the_copy.arguments[:while].reTag(arguments)       unless the_copy.arguments[:while].nil?

		# re-generate the tag now that the patterns have changed
		the_copy.generateTag()

		the_copy
	end
end
