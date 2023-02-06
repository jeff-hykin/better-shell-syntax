# frozen_string_literal: true
require 'ruby_grammar_builder'
require 'walk_up'
require_relative walk_up_until("paths.rb")
require_relative './tokens.rb'

# 
# 
# create grammar!
# 
# 
    grammar = Grammar.fromTmLanguage(PathFor[:modified_original])

# 
# imports
# 
    grammar.import(PathFor[:pattern]["comments"])

#
#
# Contexts
#
#
    # this naming thing is just a backwards compatibility thing. If all tests pass without it, it should be removed
    grammar[:$initial_context] = [
        :initial_context,
    ]
    grammar[:initial_context] = [
            :comment,
            :pipeline,
            :statement_seperator,
            :logical_expression_double,
            :logical_expression_single,
            :misc_ranges,
            :loop,
            :function_definition,
            :variable,
            :interpolation,
            :heredoc,
            :herestring,
            :redirection,
            :pathname,
            :keyword,
            :alias_statement,
            # :custom_commands,
            :command_call,
            :string,
            :support,
        ]
    grammar[:boolean] = Pattern.new(
            match: /\b(?:true|false)\b/,
            tag_as: "constant.language.$match"
        )
    grammar[:statement_context] = [
            :comment,
            :pipeline,
            :statement_seperator,
            :misc_ranges,
            :boolean,
            :redirect_number,
            :numeric_literal,
            :string,
            :variable,
            :interpolation,
            :heredoc,
            :herestring,
            :redirection,
            :pathname,
            :keyword,
            :support,
        ]
    grammar[:option_context] = [
            :misc_ranges,
            :string,
            :variable,
            :interpolation,
            :heredoc,
            :herestring,
            :redirection,
            :pathname,
            :keyword,
            :support,
        ]
    grammar[:logical_expression_context] = [
            :regex_comparison,
            :'logical-expression',
            :logical_expression_single,
            :logical_expression_double,
            :comment,
            :boolean,
            :redirect_number,
            :numeric_literal,
            :pipeline,
            :statement_seperator,
            :string,
            :variable,
            :interpolation,
            :heredoc,
            :herestring,
            :pathname,
            :keyword,
            :support,
        ]
#
#
# Patterns
#
#
    grammar[:line_continuation] = Pattern.new(
        match: Pattern.new(/\\/).lookAheadFor(/\n/),
        tag_as: "constant.character.escape.line-continuation"
    )
    
    part_of_a_variable = /[a-zA-Z_0-9-]*/ # yes.. ints can be regular variables/function-names in shells
    # this is really useful for keywords. eg: variableBounds[/new/] wont match "newThing" or "thingnew"
    variableBounds = ->(regex_pattern) do
        lookBehindToAvoid(@standard_character).then(regex_pattern).lookAheadToAvoid(@standard_character)
    end
    variable_name = variableBounds[part_of_a_variable]
    
    std_space = Pattern.new(/\s*+/)
    
    # this numeric_literal was stolen from C++, has been cleaned up some, but could have a few dangling oddities
    def generateNumericLiteral(allow_user_defined_literals: false, separator:"_")
        valid_single_character = Pattern.new(/(?:[0-9a-zA-Z_\.]|#{separator})/)
        valid_after_exponent = lookBehindFor(/[eEpP]/).then(/[+-]/)
        valid_character = valid_single_character.or(valid_after_exponent)
        end_pattern = Pattern.new(/$/)

        number_separator_pattern = Pattern.new(
            should_partial_match: [ "1#{separator}1" ],
            should_not_partial_match: [ "1#{separator}#{separator}1", "1#{separator}#{separator}" ],
            match: lookBehindFor(/[0-9a-fA-F]/).then(/#{separator}/).lookAheadFor(/[0-9a-fA-F]/),
            tag_as:"punctuation.separator.constant.numeric",
        )

        hex_digits = hex_digits = Pattern.new(
            should_fully_match: [ "1", "123456", "DeAdBeeF", "49#{separator}30#{separator}94", "DeA#{separator}dBe#{separator}eF", "dea234f4930" ],
            should_not_fully_match: [ "#{separator}3902" , "de2300p1000", "0x000" ],
            should_not_partial_match: [ "p", "x", "." ],
            match: Pattern.new(/[0-9a-fA-F]/).zeroOrMoreOf(Pattern.new(/[0-9a-fA-F]/).or(number_separator_pattern)),
            tag_as: "constant.numeric.hexadecimal",
            includes: [ number_separator_pattern ],
        )
        decimal_digits = Pattern.new(
            should_fully_match: [ "1", "123456", "49#{separator}30#{separator}94" , "1#{separator}2" ],
            should_not_fully_match: [ "#{separator}3902" , "1.2", "0x000" ],
            match: Pattern.new(/[0-9]/).zeroOrMoreOf(Pattern.new(/[0-9]/).or(number_separator_pattern)),
            tag_as: "constant.numeric.decimal",
            includes: [ number_separator_pattern ],
        )
        # 0'004'000'000 is valid (i.e. a number separator directly after the prefix)
        octal_digits = Pattern.new(
            should_fully_match: [ "1", "123456", "47#{separator}30#{separator}74" , "1#{separator}2" ],
            should_not_fully_match: [ "#{separator}3902" , "1.2", "0x000" ],
            match: oneOrMoreOf(Pattern.new(/[0-7]/).or(number_separator_pattern)),
            tag_as: "constant.numeric.octal",
            includes: [ number_separator_pattern ],
        )
        binary_digits = Pattern.new(
            should_fully_match: [ "1", "100100", "10#{separator}00#{separator}11" , "1#{separator}0" ],
            should_not_fully_match: [ "#{separator}3902" , "1.2", "0x000" ],
            match: Pattern.new(/[01]/).zeroOrMoreOf(Pattern.new(/[01]/).or(number_separator_pattern)),
            tag_as: "constant.numeric.binary",
            includes: [ number_separator_pattern ],
        )

        hex_prefix = Pattern.new(
            should_fully_match: ["0x", "0X"],
            should_partial_match: ["0x1234"],
            should_not_partial_match: ["0b010x"],
            match: Pattern.new(/\G/).then(/0[xX]/),
            tag_as: "keyword.other.unit.hexadecimal",
        )
        octal_prefix = Pattern.new(
            should_fully_match: ["0"],
            should_partial_match: ["01234"],
            match: Pattern.new(/\G/).then(/0/),
            tag_as: "keyword.other.unit.octal",
        )
        binary_prefix = Pattern.new(
            should_fully_match: ["0b", "0B"],
            should_partial_match: ["0b1001"],
            should_not_partial_match: ["0x010b"],
            match: Pattern.new(/\G/).then(/0[bB]/),
            tag_as: "keyword.other.unit.binary",
        )
        decimal_prefix = Pattern.new(
            should_partial_match: ["1234"],
            match: Pattern.new(/\G/).lookAheadFor(/[0-9.]/).lookAheadToAvoid(/0[xXbB]/),
        )
        numeric_suffix = Pattern.new(
            should_fully_match: ["u","l","UL","llU"],
            should_not_fully_match: ["lLu","uU","lug"],
            match: oneOf([
                /[uU]/,
                /[uU]ll?/,
                /[uU]LL?/,
                /ll?[uU]?/,
                /LL?[uU]?/,
                /[fF]/, # TODO: this is actually a decimal point-less floating point number
            ]).lookAheadToAvoid(/\w/),
            tag_as: "keyword.other.unit.suffix.integer",
        )

        # see https://en.cppreference.com/w/cpp/language/floating_literal
        hex_exponent = Pattern.new(
            should_fully_match: [ "p100", "p-100", "p+100", "P100" ],
            should_not_fully_match: [ "p0x0", "p-+100" ],
            match: lookBehindToAvoid(/#{separator}/).then(
                    match: /[pP]/,
                    tag_as: "keyword.other.unit.exponent.hexadecimal",
                ).maybe(
                    match: /\+/,
                    tag_as: "keyword.operator.plus.exponent.hexadecimal",
                ).maybe(
                    match: /\-/,
                    tag_as: "keyword.operator.minus.exponent.hexadecimal",
                ).then(
                    match: decimal_digits.groupless,
                    tag_as: "constant.numeric.exponent.hexadecimal",
                    includes: [ number_separator_pattern ]
                ),
        )
        decimal_exponent = Pattern.new(
            should_fully_match: [ "e100", "e-100", "e+100", "E100", ],
            should_not_fully_match: [ "e0x0", "e-+100" ],
            match: lookBehindToAvoid(/#{separator}/).then(
                    match: /[eE]/,
                    tag_as: "keyword.other.unit.exponent.decimal",
                ).maybe(
                    match: /\+/,
                    tag_as: "keyword.operator.plus.exponent.decimal",
                ).maybe(
                    match: /\-/,
                    tag_as: "keyword.operator.minus.exponent.decimal",
                ).then(
                    match: decimal_digits.groupless,
                    tag_as: "constant.numeric.exponent.decimal",
                    includes: [ number_separator_pattern ]
                ),
        )
        hex_point = Pattern.new(
            # lookBehind/Ahead because there needs to be a hex digit on at least one side
            match: lookBehindFor(/[0-9a-fA-F]/).then(/\./).or(Pattern.new(/\./).lookAheadFor(/[0-9a-fA-F]/)),
            tag_as: "constant.numeric.hexadecimal",
        )
        decimal_point = Pattern.new(
            # lookBehind/Ahead because there needs to be a decimal digit on at least one side
            match: lookBehindFor(/[0-9]/).then(/\./).or(Pattern.new(/\./).lookAheadFor(/[0-9]/)),
            tag_as: "constant.numeric.decimal.point",
        )
        floating_suffix = Pattern.new(
            should_fully_match: ["f","l","L","F"],
            should_not_fully_match: ["lLu","uU","lug","fan"],
            match: Pattern.new(/[lLfF]/).lookAheadToAvoid(/\w/),
            tag_as: "keyword.other.unit.suffix.floating-point"
        )


        hex_ending = end_pattern
        decimal_ending = end_pattern
        binary_ending = end_pattern
        octal_ending = end_pattern

        decimal_user_defined_literal_pattern = Pattern.new(
            match: maybe(Pattern.new(/\w/).lookBehindToAvoid(/[0-9eE]/).then(/\w*/)).then(end_pattern),
            tag_as: "keyword.other.unit.user-defined"
        )
        hex_user_defined_literal_pattern = Pattern.new(
            match: maybe(Pattern.new(/\w/).lookBehindToAvoid(/[0-9a-fA-FpP]/).then(/\w*/)).then(end_pattern),
            tag_as: "keyword.other.unit.user-defined"
        )
        normal_user_defined_literal_pattern = Pattern.new(
            match: maybe(Pattern.new(/\w/).lookBehindToAvoid(/[0-9]/).then(/\w*/)).then(end_pattern),
            tag_as: "keyword.other.unit.user-defined"
        )

        if allow_user_defined_literals
            hex_ending     = hex_user_defined_literal_pattern
            decimal_ending = decimal_user_defined_literal_pattern
            binary_ending  = normal_user_defined_literal_pattern
            octal_ending   = normal_user_defined_literal_pattern
        end

        #
        # How this works
        #
        # first a range (the whole number) is found
        # then, after the range is found, it starts to figure out what kind of number/constant it is
        # it does this by matching one of the includes
        return Pattern.new(
            match: lookBehindToAvoid(/\w-/).lookBehindToAvoid(/\w/).then(/\.?\d/).zeroOrMoreOf(valid_character).lookAheadFor(/\s|$/),
            includes: [
                PatternRange.new(
                    start_pattern: lookAheadFor(/./),
                    end_pattern: end_pattern,
                    # only a single include pattern should match
                    includes: [
                        # floating point
                        hex_prefix    .maybe(hex_digits    ).then(hex_point    ).maybe(hex_digits    ).maybe(hex_exponent    ).maybe(floating_suffix).then(hex_ending),
                        decimal_prefix.maybe(decimal_digits).then(decimal_point).maybe(decimal_digits).maybe(decimal_exponent).maybe(floating_suffix).then(decimal_ending),
                        # numeric
                        binary_prefix .then(binary_digits )                        .maybe(numeric_suffix).then(binary_ending ),
                        octal_prefix  .then(octal_digits  )                        .maybe(numeric_suffix).then(octal_ending  ),
                        hex_prefix    .then(hex_digits    ).maybe(hex_exponent    ).maybe(numeric_suffix).then(hex_ending    ),
                        decimal_prefix.then(decimal_digits).maybe(decimal_exponent).maybe(numeric_suffix).then(decimal_ending),
                    ]
                )
            ]
        )
    end
    grammar[:numeric_literal] = Pattern.new(
        tag_as: "constant.numeric",
        match: generateNumericLiteral(),
    )
    grammar[:redirect_number] = lookBehindFor(/\s/).then(
        oneOf([
            Pattern.new(
                tag_as: "keyword.operator.redirect.stdout",
                match: /1/,
            ),
            Pattern.new(
                tag_as: "keyword.operator.redirect.stderr",
                match: /2/,
            ),
            Pattern.new(
                tag_as: "keyword.operator.redirect.$match",
                match: /\d+/,
            ),
        ]).lookAheadFor(/>/)
    )
    
    # 
    # comments
    #
    grammar[:comment] = Pattern.new(
        Pattern.new(
            Pattern.new(/^/).or(/\s++/)
        ).then(
            Pattern.new(
                tag_as: "comment.line.number-sign meta.shebang",
                match: Pattern.new(
                    Pattern.new(
                        match: /#!/,
                        tag_as: "punctuation.definition.comment.shebang"
                    ).then(/.*/)
                ),
            ).or(
                tag_as: "comment.line.number-sign",
                match: Pattern.new(
                    Pattern.new(
                        match: /#/,
                        tag_as: "punctuation.definition.comment"
                    ).then(/.*/)
                ),
            )
        )
    )
    
    # 
    # punctuation / operators
    # 
    # replaces the old list pattern
    grammar[:statement_seperator] = Pattern.new(
            match: /;/,
            tag_as: "punctuation.terminator.statement.semicolon"
        ).or(
            match: /&&/,
            tag_as: "punctuation.separator.statement.and"
        ).or(
            match: /\|\|/,
            tag_as: "punctuation.separator.statement.or"
        ).or(
            match: /&/,
            tag_as: "punctuation.separator.statement.background"
        ).or(
            /\n/
        )
    statement_end = /[|&;]/
    
    # function thing() {}
    # thing() {}
    function_name_pattern = /[^ \t\n\r\(\)=]+/ 
    # ^ what is actually allowed by POSIX is not the same as what shells actually allow
    # so this pattern tries to be as flexible as possible
    grammar[:function_definition] = PatternRange.new(
        tag_as: "meta.function",
        start_pattern: std_space.then(
            Pattern.new(
                # this is the case with the function keyword
                Pattern.new(
                    match: /\bfunction /,
                    tag_as: "storage.type.function"
                ).then(std_space).then(
                    match: function_name_pattern,
                    tag_as: "entity.name.function",
                ).maybe(
                    Pattern.new(
                        match: /\(/,
                        tag_as: "punctuation.definition.arguments",
                    ).then(std_space).then(
                        match: /\)/,
                        tag_as: "punctuation.definition.arguments",
                    )
                )
            ).or(
                # no function keyword
                Pattern.new(
                    match: function_name_pattern,
                    tag_as: "entity.name.function",
                ).then(
                    std_space
                ).then(
                    match: /\(/,
                    tag_as: "punctuation.definition.arguments",
                ).then(std_space).then(
                    match: /\)/,
                    tag_as: "punctuation.definition.arguments",
                )
            )
        ),
        end_pattern: lookBehindFor("}"),
        includes: [
            PatternRange.new(
                tag_as: "meta.function.body",
                start_pattern: Pattern.new(
                    match: "{",
                    tag_as: "punctuation.definition.group punctuation.section.function.definition",
                ),
                end_pattern: Pattern.new(
                    match: "}",
                    tag_as: "punctuation.definition.group punctuation.section.function.definition",
                ),
                includes: [
                    :initial_context,
                ],
            ),
        ],
    )
    
    grammar[:modifiers] = modifier = Pattern.new(
        # TODO: generate this using @tokens
        match: /(?<=^|;|&|\s)(?:export|declare|typeset|local|readonly)(?=\s|;|&|$)/,
        tag_as: "storage.modifier.$match",
    )
    
    normal_assignment = PatternRange.new(
            tag_as: "meta.expression.assignment",
            start_pattern: assignment_start = std_space.maybe(modifier.then(std_space)).then(
                    Pattern.new(
                        match: variable_name,
                        tag_as: "variable.other.assignment",
                    ).maybe(
                        Pattern.new(
                            match: "[",
                            tag_as: "punctuation.definition.array.access",
                        ).then(
                            match: maybe("$").then(variable_name).or("@").or("*"),
                            tag_as: "variable.other.assignment",
                        ).then(
                            match: "]",
                            tag_as: "punctuation.definition.array.access",
                        ),
                    )
                ).then(
                    Pattern.new(
                        match: /\=/,
                        tag_as: "keyword.operator.assignment",
                    ).or(
                        match: /\+\=/,
                        tag_as: "keyword.operator.assignment.compound",
                    ).or(
                        match: /\-\=/,
                        tag_as: "keyword.operator.assignment.compound",
                    )
                ),
            end_pattern: assignment_end = lookAheadFor(/ |$/).or(grammar[:statement_seperator]),
            includes: [
                :comment,
                :argument_context,
            ]
        )
    grammar[:assignment] = [
        # assignment with ()'s
        PatternRange.new(
            tag_as: "meta.expression.assignment",
            start_pattern: assignment_start.then(std_space).then(
                match:"(",
                tag_as: "punctuation",
            ),
            end_pattern: Pattern.new(
                match: ")",
                tag_as: "punctuation",
            ),
            includes: [ 
                :comment,
                :argument_context,
            ]
        ),
        normal_assignment
    ]
    grammar[:alias_statement] = PatternRange.new(
        tag_as: "meta.expression.assignment",
        start_pattern:  Pattern.new(
                match: /alias/,
                tag_as: "storage.type.alias"
            ).then(std_space).then(assignment_start),
        end_pattern: assignment_end,
        includes: [ :statement_context ]
    )
    
    possible_pre_command_characters   = /(?:^|;|\||&|!|\(|\{|\`)/
    basic_possible_command_start      = lookAheadToAvoid(/(?:!|%|&|\||\(|\)|\{|\[|<|>|#|\n|$|;|\s)/)
    possible_argument_start  = lookAheadToAvoid(/(?:%|&|\||\(|\[|#|\n|$|;)/)
    command_end              = lookAheadFor(/;|\||&|\n|\)|\`|\{|\}| *#|\]/).lookBehindToAvoid(/\\/)
    unquoted_string_end      = lookAheadFor(/\s|;|\||&|$|\n|\)|\`/)
    invalid_literals         = Regexp.quote(@tokens.representationsThat(:areInvalidLiterals).join(""))
    valid_literal_characters = Regexp.new("[^\s\n#{invalid_literals}]+")
    any_builtin_name         = @tokens.representationsThat(:areBuiltInCommands).map{ |value| Regexp.quote(value) }.join("|")
    any_builtin_name         = Regexp.new("(?:#{any_builtin_name})")
    any_builtin_name         = variableBounds[any_builtin_name]
    any_builtin_control_flow = @tokens.representationsThat(:areBuiltInCommands, :areControlFlow).map{ |value| Regexp.quote(value) }.join("|")
    any_builtin_control_flow = Regexp.new("(?:#{any_builtin_control_flow})")
    any_builtin_control_flow = variableBounds[any_builtin_control_flow]
    possible_command_start   = basic_possible_command_start.lookAheadToAvoid(
        Regexp.new(
            @tokens.representationsThat(
                :areShellReservedWords,
                :areControlFlow
            # escape before putting into regex
            ).map{
                |value| Regexp.quote(value) 
            # add word-delimiter
            }.map{
                |value| value + '\b'
            # "OR" join
            }.join("|")
        )
    )
    puts "possible_command_start is: #{possible_command_start} "
    
    grammar[:keyword] = [
        Pattern.new(
            # TODO: generate this using @tokens
            match: /(?<=^|;|&|\s)(?:then|else|elif|fi|for|in|do|done|select|case|continue|esac|while|until|return)(?=\s|;|&|$)/,
            tag_as: "keyword.control.$match",
        ),
        # modifier
    ]
    
    # 
    # 
    # commands (very complicated becase sadly a command name can span multiple lines)
    # 
    #
    generateUnquotedArugment = ->(tag_as) do
        std_space.then(
            tag_as: tag_as,
            match: Pattern.new(valid_literal_characters).lookAheadToAvoid(/>/), # ex: 1>&2
            includes: [
                # wildcard
                Pattern.new(
                    match: /\*/,
                    tag_as: "variable.language.special.wildcard"
                ),
                :variable,
                :numeric_literal,
                variableBounds[grammar[:boolean]],
            ]
        ) 
    end
    unquoted_command_prefix = generateUnquotedArugment["entity.name.command"]
    grammar[:start_of_double_quoted_command_name] = Pattern.new(
        tag_as: "meta.command_name.quoted string.quoted.double punctuation.definition.string.begin entity.name.command",
        match: Pattern.new(
            Pattern.new(
                basic_possible_command_start
            ).maybe(unquoted_command_prefix).oneOf([
                /\$"/,
                /"/,
            ])
        ),
    )
    
    grammar[:start_of_single_quoted_command_name] = Pattern.new(
        tag_as: "meta.command_name.quoted string.quoted.single punctuation.definition.string.begin entity.name.command",
        match: Pattern.new(
            Pattern.new(
                basic_possible_command_start
            ).maybe(unquoted_command_prefix).oneOf([
                /\$'/,
                /'/,
            ])
        ),
    )
    
    grammar[:continuation_of_double_quoted_command_name] = PatternRange.new(
        tag_content_as: "meta.command_name.continuation string.quoted.double entity.name.command",
        start_pattern: Pattern.new(
            Pattern.new(
                /\G/
            ).lookBehindFor(/"/)
        ),
        end_pattern: Pattern.new(
            match: "\"",
            tag_as: "punctuation.definition.string.end.shell entity.name.command",
        ),
        includes: [
            Pattern.new(
                match: /\\[\$\n`"\\]/,
                tag_as: "constant.character.escape.shell",
            ),
            :variable,
            :interpolation,
        ],
    )
    
    grammar[:continuation_of_single_quoted_command_name] = PatternRange.new(
        tag_content_as: "meta.command_name.continuation string.quoted.single entity.name.command",
        start_pattern: Pattern.new(
            Pattern.new(
                /\G/
            ).lookBehindFor(/'/)
        ),
        end_pattern: Pattern.new(
            match: "\'",
            tag_as: "punctuation.definition.string.end.shell entity.name.command",
        ),
    )
    
    grammar[:command_name] = Pattern.new(
        tag_as: "meta.command_name",
        match: Pattern.new(
            Pattern.new(
                possible_command_start
            ).then(
                modifier.or(
                    tag_as: "entity.name.command",
                    match: lookAheadToAvoid(/\\\n?$/).oneOf([ /\$?"/, /.+?/ ]), # the start of a string command or normal command
                    includes: [
                        Pattern.new(
                            match: any_builtin_control_flow,
                            tag_as: "keyword.control.$match",
                        ),
                        Pattern.new(
                            match: any_builtin_name,
                            tag_as: "support.function.builtin",
                        ),
                        :variable,
                    ]
                )
            ).then(
                lookAheadFor(/\s/).or(command_end)
            )
        ),
    )
    grammar[:argument_context] = [
        generateUnquotedArugment["string.unquoted.argument"],
        :statement_context,
    ]
    grammar[:argument] = PatternRange.new(
        tag_as: "meta.argument",
        start_pattern: Pattern.new(/\s++/).then(possible_argument_start),
        end_pattern: unquoted_string_end,
        includes: [
            :argument_context,
            :line_continuation,
        ]
    )
    grammar[:option] = PatternRange.new(
        tag_content_as: "string.unquoted.argument constant.other.option",
        start_pattern: Pattern.new(  
            Pattern.new(/\s++/).then(
                match: /-/,
                tag_as: "string.unquoted.argument constant.other.option.dash"
            ).then(
                match: basic_possible_command_start,
                tag_as: "string.unquoted.argument constant.other.option",
            )
        ),
        end_pattern: lookAheadFor(/\s/).or(command_end),
        includes: [
            :option_context,
        ]
    )
    grammar[:simple_options] = zeroOrMoreOf(
        Pattern.new(/\s++/).then(
            match: /\-/,
            tag_as: "string.unquoted.argument constant.other.option.dash"
        ).then(
            match: /\w+/,
            tag_as: "string.unquoted.argument constant.other.option"
        )
    )
    keywords = @tokens.representationsThat(:areShellReservedWords, :areNotModifiers)
    keyword_patterns = /#{keywords.map { |each| each+'\W|'+each+'\$' } .join('|')}/
    valid_after_patterns = /#{['if','elif','then', 'else', 'while', 'do'].map { |each| '^'+each+' | '+each+' |\t'+each+' ' } .join('|')}/
    empty_line = /^[ \t]*+$/
    grammar[:command_call] = PatternRange.new(
        zeroLengthStart?: true,
        zeroLengthEnd?: true,
        tag_as: "meta.statement",
        # blank lines screw this pattern up, which is what the first lookAheadToAvoid is fixing
        start_pattern: Pattern.new(
            lookAheadToAvoid(empty_line).then(
                lookBehindFor(valid_after_patterns).or(lookBehindFor(possible_pre_command_characters))
            ).then(std_space).lookAheadToAvoid(keyword_patterns),
        ),
        end_pattern: command_end,
        includes: [
            :function_definition,
            :assignment,
            # This pattern exclusively handleds commands with quotes
            PatternRange.new(
                tag_as: "meta.command",
                start_pattern: std_space.oneOf([
                    grammar[:start_of_single_quoted_command_name],
                    grammar[:start_of_double_quoted_command_name],
                ]),
                end_pattern: command_end,
                includes: [
                    # same as the grammar string, but instead looks behind for the "
                    :continuation_of_single_quoted_command_name,
                    :continuation_of_double_quoted_command_name,
                    :line_continuation,
                    :option,
                    # this pattern only happens as a rare edgecase 
                    # if this is the command: "$1"_command_postfix
                    # then this pattern matches the trailing '_command_postfix' part 
                    Pattern.new(
                        lookBehindFor(/'|"/).then(
                            tag_as: "entity.name.command",
                            match: /[^ \n\t\r]+/,
                        ),
                    ),
                    :argument,
                    # :custom_commands,
                    :statement_context
                ],
            ),
            # This pattern exclusively handleds commands that don't use quotes
            # (and I don't think it can be combined with the above pattern without breaking multi-line quoted commands)
            PatternRange.new(
                tag_as: "meta.command",
                start_pattern: std_space.then(grammar[:command_name]),
                end_pattern: command_end,
                includes: [
                    # same as the grammar string, but instead looks behind for the "
                    :line_continuation,
                    :option,
                    :argument,
                    # :custom_commands,
                    :statement_context
                ],
            ),
            :line_continuation,
            :statement_context,
        ]
    )
    grammar[:custom_commands] = [
    ]
    grammar[:custom_command_names] = [
    ]
    grammar[:logical_expression_single] = PatternRange.new(
        tag_as: "meta.scope.logical-expression",
        start_pattern: Pattern.new(
                match: /\[/,
                tag_as: "punctuation.definition.logical-expression",
            ),
        end_pattern: Pattern.new(
                match: /\]/,
                tag_as: "punctuation.definition.logical-expression"
            ),
        includes: [
            :logical_expression_context
        ],
    )
    grammar[:logical_expression_double] = PatternRange.new(
        tag_as: "meta.scope.logical-expression",
        start_pattern: Pattern.new(
                match: /\[\[/,
                tag_as: "punctuation.definition.logical-expression",
            ),
        end_pattern: Pattern.new(
                match: /\]\]/,
                tag_as: "punctuation.definition.logical-expression"
            ),
        includes: [
            :logical_expression_context
        ],
    )
    grammar[:misc_ranges] = [
        :logical_expression_single,
        :logical_expression_double,
        # 
        # handle (())
        # 
        PatternRange.new(
            tag_as: "meta.arithmetic",
            start_pattern: Pattern.new(
                    tag_as: "punctuation.section.arithmetic",
                    match: /\(\(/
                ),
            end_pattern: Pattern.new(
                    tag_as: "punctuation.section.arithmetic",
                    match: /\)\)/
                ),
            includes: [
                # TODO: add more stuff here
                # see: http://tiswww.case.edu/php/chet/bash/bashref.html#Shell-Arithmetic
                :math,
            ]
        ),
        # 
        # handle ()
        # 
        PatternRange.new(
            tag_as: "meta.scope.subshell",
            start_pattern: Pattern.new(
                    tag_as: "punctuation.definition.subshell",
                    match: lookBehindToAvoid("=").then(/\(/)
                ),
            end_pattern: Pattern.new(
                    tag_as: "punctuation.definition.subshell",
                    match: /\)/
                ),
            includes: [
                :initial_context,
            ]
        ),
        # 
        # groups (?) 
        # 
        PatternRange.new(
            tag_as: "meta.scope.group",
            start_pattern: Pattern.new(
                    tag_as: "punctuation.definition.group",
                    match: /{/
                ),
            end_pattern: Pattern.new(
                    tag_as: "punctuation.definition.group",
                    match: /}/
                ),
            includes: [
                :initial_context
            ]
        ),
    ]
    
    grammar[:regex_comparison] = Pattern.new(
            tag_as: "keyword.operator.logical.regex",
            match: /\=~/,
        )
    
    def generateVariable(regex_after_dollarsign, tag)
        Pattern.new(
            match: Pattern.new(
                match: /\$/,
                tag_as: "punctuation.definition.variable #{tag}"
            ).then(
                match: Pattern.new(regex_after_dollarsign).lookAheadToAvoid(/\w/),
                tag_as: tag,
            )
        )
    end
    
    grammar[:variable] = [
        generateVariable(/\@/, "variable.parameter.positional.all"),
        generateVariable(/[0-9]/, "variable.parameter.positional"),
        generateVariable(/\{[0-9]+\}/, "variable.parameter.positional"),
        generateVariable(/[-*#?$!0_]/, "variable.language.special"),
        PatternRange.new(
            start_pattern: Pattern.new(
                    match: Pattern.new(
                        match: /\$/,
                        tag_as: "punctuation.definition.variable punctuation.section.bracket.curly.variable.begin"
                    ).then(
                        match: /\{/,
                        tag_as: "punctuation.section.bracket.curly.variable.begin",
                        
                    )
                ),
            end_pattern: Pattern.new(
                    match: /\}/,
                    tag_as: "punctuation.section.bracket.curly.variable.end",
                ),
            includes: [
                Pattern.new(
                    match: /!|:[-=?]?|\*|@|##|#|%%|%|\//,
                    tag_as: "keyword.operator.expansion",
                ),
                Pattern.new(
                    Pattern.new(
                        match: /\[/,
                        tag_as: "punctuation.section.array",
                    ).then(
                        match: /[^\]]+/,
                    ).then(
                        match: /\]/,
                        tag_as: "punctuation.section.array",
                    )
                ),
                :variable,
                :string,
            ]
        ),
        # normal variables
        generateVariable(/\w+/, "variable.other.normal")
    ]
    
    # 
    # 
    # strings
    # 
    # 
        basic_escape_char = Pattern.new(
            match: /\\./,
            tag_as: "constant.character.escape",
        )
        grammar[:double_quote_escape_char] = Pattern.new(
            match: /\\[\$`"\\\n]/,
            tag_as: "constant.character.escape",
        )
        
        grammar[:string] = [
            Pattern.new(
                match: /\\./,
                tag_as: "constant.character.escape.shell",
            ),
            PatternRange.new(
                tag_as: "string.quoted.single.shell",
                start_pattern: Pattern.new(
                    match: "'",
                    tag_as: "punctuation.definition.string.begin.shell",
                ),
                end_pattern: Pattern.new(
                    match: "'",
                    tag_as: "punctuation.definition.string.end.shell",
                ),
            ),
            PatternRange.new(
                tag_as: "string.quoted.double.shell",
                start_pattern: Pattern.new(
                    match:  /\$?"/,
                    tag_as: "punctuation.definition.string.begin.shell",
                ),
                end_pattern: Pattern.new(
                    match: "\"",
                    tag_as: "punctuation.definition.string.end.shell",
                ),
                includes: [
                    Pattern.new(
                        match: /\\[\$\n`"\\]/,
                        tag_as: "constant.character.escape.shell",
                    ),
                    :variable,
                    :interpolation,
                ]
            ),
            PatternRange.new(
                tag_as: "string.quoted.single.dollar.shell",
                start_pattern: Pattern.new(
                    match: /\$'/,
                    tag_as: "punctuation.definition.string.begin.shell",
                ),
                end_pattern: Pattern.new(
                    match: "'",
                    tag_as: "punctuation.definition.string.end.shell",
                ),
                includes: [
                    Pattern.new(
                        match: /\\(?:a|b|e|f|n|r|t|v|\\|')/,
                        tag_as: "constant.character.escape.ansi-c.shell",
                    ),
                    Pattern.new(
                        match: /\\[0-9]{3}"/,
                        tag_as: "constant.character.escape.octal.shell",
                    ),
                    Pattern.new(
                        match: /\\x[0-9a-fA-F]{2}"/,
                        tag_as: "constant.character.escape.hex.shell",
                    ),
                    Pattern.new(
                        match: /\\c."/,
                        tag_as: "constant.character.escape.control-char.shell",
                    )
                ]
            ),
        ]
    
        # 
        # heredocs
        # 
            generateHeredocRanges = ->(name_pattern, tag_content_as:nil, includes:[]) do
                [
                    # <<-"HEREDOC"
                    PatternRange.new(
                        tag_content_as: "string.quoted.heredoc.indent",
                        start_pattern: Pattern.new(
                            Pattern.new(
                                match: lookBehindToAvoid(/</).then(/<<-/),
                                tag_as: "keyword.operator.heredoc",
                            ).then(std_space).then(
                                match: /"|'/,
                                reference: "start_quote"
                            ).then(std_space).then(
                                match: name_pattern,
                                reference: "delimiter",
                                tag_as: "punctuation.definition.string.heredoc",
                            ).lookAheadFor(/\s|;|&|<|"|'/).matchResultOf(
                                "start_quote"
                            ).then(
                                match: /.*/,
                                includes: [
                                    :statement_context,
                                ],
                            )
                        ),
                        end_pattern: Pattern.new(
                            tag_as: "punctuation.definition.string.heredoc",
                            match: Pattern.new(
                                Pattern.new(/^\t*/).matchResultOf(
                                    "delimiter"
                                ).lookAheadFor(/\s|;|&|$/),
                            ),
                        ),
                        includes: includes,
                    ),
                    # <<"HEREDOC"
                    PatternRange.new(
                        tag_content_as: "string.quoted.heredoc.no-indent",
                        start_pattern: Pattern.new(
                            Pattern.new(
                                match: lookBehindToAvoid(/</).then(/<</).lookAheadToAvoid(/</),
                                tag_as: "keyword.operator.heredoc",
                            ).then(std_space).then(
                                match: /"|'/,
                                reference: "start_quote"
                            ).then(std_space).then(
                                match: name_pattern,
                                reference: "delimiter",
                                tag_as: "punctuation.definition.string.heredoc",
                            ).lookAheadFor(/\s|;|&|<|"|'/).matchResultOf(
                                "start_quote"
                            ).then(
                                match: /.*/,
                                includes: [
                                    :statement_context,
                                ],
                            )
                        ),
                        end_pattern: Pattern.new(
                            tag_as: "punctuation.definition.string.heredoc",
                            match: Pattern.new(
                                Pattern.new(/^/).matchResultOf(
                                    "delimiter"
                                ).lookAheadFor(/\s|;|&|$/),
                            ),
                        ),
                        includes: includes,
                    ),
                    # <<-HEREDOC
                    PatternRange.new(
                        tag_content_as: "string.unquoted.heredoc.indent",
                        start_pattern: Pattern.new(
                            Pattern.new(
                                match: lookBehindToAvoid(/</).then(/<<-/),
                                tag_as: "keyword.operator.heredoc",
                            ).then(std_space).then(
                                match: name_pattern,
                                reference: "delimiter",
                                tag_as: "punctuation.definition.string.heredoc",
                            ).lookAheadFor(/\s|;|&|<|"|'/).then(
                                match: /.*/,
                                includes: [
                                    :statement_context,
                                ],
                            )
                        ),
                        end_pattern: Pattern.new(
                            tag_as: "punctuation.definition.string.heredoc",
                            match: Pattern.new(
                                Pattern.new(/^\t*/).matchResultOf(
                                    "delimiter"
                                ).lookAheadFor(/\s|;|&|$/),
                            )
                        ),
                        includes: [
                            :double_quote_escape_char,
                            :variable,
                            :interpolation,
                            *includes,
                        ]
                    ),
                    # <<HEREDOC
                    PatternRange.new(
                        tag_content_as: "string.unquoted.heredoc.no-indent",
                        start_pattern: Pattern.new(
                            Pattern.new(
                                match: lookBehindToAvoid(/</).then(/<</).lookAheadToAvoid(/</),
                                tag_as: "keyword.operator.heredoc",
                            ).then(std_space).then(
                                match: name_pattern,
                                reference: "delimiter",
                                tag_as: "punctuation.definition.string.heredoc",
                            ).lookAheadFor(/\s|;|&|<|"|'/).then(
                                match: /.*/,
                                includes: [
                                    :statement_context,
                                ],
                            )
                        ),
                        end_pattern: Pattern.new(
                            tag_as: "punctuation.definition.string.heredoc",
                            match: Pattern.new(
                                Pattern.new(/^/).matchResultOf(
                                    "delimiter"
                                ).lookAheadFor(/\s|;|&|$/),
                            )
                        ),
                        includes: [
                            :double_quote_escape_char,
                            :variable,
                            :interpolation,
                            *includes,
                        ]
                    ),
                ]
            end
            
            grammar[:heredoc] = generateHeredocRanges[variable_name]
    
    # 
    # regex
    # 
        grammar[:regexp] = [
            # regex highlight is not the same as Perl, Ruby, or JavaScript so extra work needs to be done here
            Pattern.new(/.+/) # leaving this list empty causes an error so add generic pattern
        ]

#
# Save
#
name = "shell"
grammar.save_to(
    syntax_name: name,
    syntax_dir: "./autogenerated",
    tag_dir: "./autogenerated",
)