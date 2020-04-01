require 'json'
require 'yaml'
require 'set'
require 'deep_clone' # gem install deep_clone
require 'pathname'

class PatternRange
    attr_accessor :as_tag, :repository_name, :arguments

    def __deep_clone__()
        PatternRange.new(@arguments.__deep_clone__)
    end

    def initialize(arguments)
        # parameters:
            # comment: (idk why youd ever use this, but it exists for backwards compatibility)
            # tag_as:
            # tag_content_as:
            # apply_end_pattern_last:
            # while:
            # start_pattern:
            # end_pattern:
            # includes:
            # repository:
            # repository_name:

        # save all of the arguments for later
        @arguments = arguments
        # generate the tag so that errors show up
        self.generateTag()
    end

    def generateTag()

        # generate a tag version
        @as_tag = {}
        key_arguments = @arguments.clone

        #
        # comment
        #
        comment = key_arguments[:comment]
        key_arguments.delete(:comment)
        if comment != nil && comment != ""
            @as_tag[:name] = comment
        end

        #
        # tag_as
        #
        tag_name = key_arguments[:tag_as]
        key_arguments.delete(:tag_as)
        if tag_name != nil && tag_name != ""
            @as_tag[:name] = tag_name
        end

        #
        # tag_content_as
        #
        tag_content_name = key_arguments[:tag_content_as]
        key_arguments.delete(:tag_content_as)
        if tag_content_name != nil && tag_content_name != ""
            @as_tag[:contentName] = tag_content_name
        end

        #
        # apply_end_pattern_last
        #
        apply_end_pattern_last = key_arguments[:apply_end_pattern_last]
        key_arguments.delete(:apply_end_pattern_last)
        if apply_end_pattern_last == 1 || apply_end_pattern_last == true
            @as_tag[:applyEndPatternLast] = apply_end_pattern_last
        end

        #
        # while
        #
        while_statement = key_arguments[:while]
        key_arguments.delete(:while)
        if while_statement != nil && while_statement != //
            @as_tag[:while] = while_statement
            while_pattern_as_tag = while_statement.to_tag(without_optimizations: true)
            while_captures = while_pattern_as_tag[:captures]
            if while_captures != {} && while_captures.to_s != ""
                @as_tag[:whileCaptures] = while_captures
            end
        end

        #
        # start_pattern
        #
        start_pattern = key_arguments[:start_pattern]
        if not ( (start_pattern.is_a? Regexp) and start_pattern != // )
            raise "The start pattern for a PatternRange needs to be a non-empty regular expression\nThe PatternRange causing the problem is:\n#{key_arguments}"
        end
        start_pattern_as_tag =  start_pattern.to_tag(without_optimizations: true)
        # prevent accidental zero length matches
        pattern = nil
        # suppress the regex warnings "nested repeat operator '?' and '+' was replaced with '*' in regular expression"
        suppress_output do
            pattern = /#{start_pattern_as_tag[:match]}/
        end
        if "" =~ pattern and not key_arguments[:zeroLengthStart?] and not pattern.inspect == "/\G/"
            puts "Warning: #{/#{start_pattern_as_tag[:match]}/.inspect}\nmatches the zero length string (\"\").\n\n"
            puts "This means that the patternRange always matches"
            puts "You can disable this warning by settting :zeroLengthStart? to true."
            puts "The tag for this patternRange is \"#{@as_tag[:name]}\"\n\n"
        end
        key_arguments.delete(:zeroLengthStart?)

        @as_tag[:begin] = start_pattern_as_tag[:match]
        key_arguments.delete(:start_pattern)
        begin_captures = start_pattern_as_tag[:captures]
        if begin_captures != {} && begin_captures.to_s != ""
            @as_tag[:beginCaptures] = begin_captures
        end

        #
        # end_pattern
        #
        end_pattern = key_arguments[:end_pattern]
        if @as_tag[:while] == nil and not end_pattern.is_a?(Regexp) or end_pattern == //
            raise "The end pattern for a PatternRange needs to be a non-empty regular expression\nThe PatternRange causing the problem is:\n#{key_arguments}"
        end
        if end_pattern != nil
            end_pattern_as_tag = end_pattern.to_tag(without_optimizations: true, ignore_repository_entry: true)
            @as_tag[:end] = end_pattern_as_tag[:match]
            key_arguments.delete(:end_pattern)
            end_captures = end_pattern_as_tag[:captures]
            if end_captures != {} && end_captures.to_s != ""
                @as_tag[:endCaptures] = end_captures
            end
        end
        #
        # includes
        #
        patterns = Grammar.convertIncludesToPatternList(key_arguments[:includes])
        key_arguments.delete(:includes)
        if patterns != []
            @as_tag[:patterns] = patterns
        end

        #
        # repository
        #
        repository = key_arguments[:repository]
        key_arguments.delete(:repository)
        if (repository.is_a? Hash) && (repository != {})
            @as_tag[:repository] = Grammar.convertRepository(repository)
        end

        # TODO, add more error checking. key_arguments should be empty at this point
    end

    def to_tag(ignore_repository_entry: false)
        # if it hasn't been generated somehow, then generate it
        if @as_tag == nil
            self.generateTag()
        end

        if ignore_repository_entry
            return @as_tag
        end

        if @repository_name != nil
            return {
                include: "##{@repository_name}"
            }
        end
        return @as_tag
    end

    def reTag(arguments)
        # create a copy
        the_copy = self.__deep_clone__()
        # reTag the patterns
        the_copy.arguments[:start_pattern] = the_copy.arguments[:start_pattern].reTag(arguments)
        the_copy.arguments[:end_pattern  ] = the_copy.arguments[:end_pattern  ].reTag(arguments) unless the_copy.arguments[:end_pattern  ] == nil
        the_copy.arguments[:while        ] = the_copy.arguments[:while        ].reTag(arguments) unless the_copy.arguments[:while        ] == nil
        # re-generate the tag now that the patterns have changed
        the_copy.generateTag()
        return the_copy
    end
end
