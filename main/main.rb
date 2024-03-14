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
            :normal_statement_seperator,
            :logical_expression_double,
            :logical_expression_single,
            :case_pattern,
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
            :normal_statement,
            :string,
            :support,
        ]
    grammar[:boolean] = Pattern.new(
            match: /\b(?:true|false)\b/,
            tag_as: "constant.language.$match"
        )
    grammar[:normal_statement_context] = [
            :comment,
            :pipeline,
            :normal_statement_seperator,
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
            :normal_statement_seperator,
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
    empty_line = /^[ \t]*+$/
    line_continuation = /\\\n?$/
    grammar[:line_continuation] = Pattern.new(
        match: Pattern.new(/\\/).lookAheadFor(/\n/),
        tag_as: "constant.character.escape.line-continuation"
    )
    
    part_of_a_variable = /[a-zA-Z_0-9-]+/ # yes.. ints can be regular variables/function-names in shells
    # this is really useful for keywords. eg: variableBounds[/new/] wont match "newThing" or "thingnew"
    variableBounds = ->(regex_pattern) do
        lookBehindToAvoid(@standard_character).then(regex_pattern).lookAheadToAvoid(@standard_character)
    end
    variable_name = variableBounds[part_of_a_variable]
    
    std_space = Pattern.new(/[ \t]*+/)
    
    # this numeric_literal was stolen from C++, has been cleaned up some, but could have a few dangling oddities
    grammar[:numeric_literal] = lookBehindFor(/=| |\t|^|\{|\(|\[/).then(
        Pattern.new(
            match: /0[xX][0-9A-Fa-f]+/,
            tag_as: "constant.numeric constant.numeric.hex"
        ).or(
            match: /0\d+/,
            tag_as: "constant.numeric constant.numeric.octal"
        ).or(
            match: /\d{1,2}#[0-9a-zA-Z@_]+/,
            tag_as: "constant.numeric constant.numeric.other"
        ).or(
            match: /-?\d+(?:\.\d+)/,
            tag_as: "constant.numeric constant.numeric.decimal"
        ).or(
            match: /-?\d+(?:\.\d+)+/,
            tag_as: "constant.numeric constant.numeric.version"
        ).or(
            match: /-?\d+/,
            tag_as: "constant.numeric constant.numeric.integer"
        )
    ).lookAheadFor(/ |\t|$|\}|\)|;/)
    grammar[:redirect_number] = lookBehindFor(/[ \t]/).then(
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
            Pattern.new(/^/).or(/[ \t]++/)
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
    grammar[:normal_statement_seperator] = Pattern.new(
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
        )
    statement_end = /[|&;]/
    
    # function thing() {}
    # thing() {}
    function_name_pattern = /[^ \t\n\r\(\)="']+/ 
    # ^ what is actually allowed by POSIX is not the same as what shells actually allow
    # so this pattern tries to be as flexible as possible
    grammar[:function_definition] = PatternRange.new(
        tag_as: "meta.function",
        start_pattern: std_space.then(
            Pattern.new(
                # this is the case with the function keyword
                Pattern.new(
                    match: /\bfunction\b/,
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
        apply_end_pattern_last: true,
        end_pattern: lookBehindFor(/\}|\)/),
        includes: [
            # exists soley to eat one char after the "func_name()" so that the lookBehind doesnt immediately match
            Pattern.new(/\G(?:\t| |\n)/),
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
            PatternRange.new(
                tag_as: "meta.function.body",
                start_pattern: Pattern.new(
                    match: "(",
                    tag_as: "punctuation.definition.group punctuation.section.function.definition",
                ),
                end_pattern: Pattern.new(
                    match: ")",
                    tag_as: "punctuation.definition.group punctuation.section.function.definition",
                ),
                includes: [
                    :initial_context,
                ],
            ),
            :initial_context,
        ],
    )
    
    grammar[:modifiers] = modifier = Pattern.new(
        match: /(?<=^|;|&|[ \t])(?:#{@tokens.representationsThat(:areModifiers).join("|")})(?=[ \t]|;|&|$)/,
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
            end_pattern: assignment_end = lookAheadFor(/ |\t|$/).or(grammar[:normal_statement_seperator]),
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
        includes: [ :normal_statement_context ]
    )
    
    possible_pre_command_characters   = /(?:^|;|\||&|!|\(|\{|\`)/
    basic_possible_command_start      = lookAheadToAvoid(/(?:!|&|\||\(|\)|\{|\[|<|>|#|\n|$|;|[ \t])/)
    possible_argument_start  = lookAheadToAvoid(/(?:&|\||\(|\[|#|\n|$|;)/)
    command_end              = lookAheadFor(/;|\||&|\n|\)|\`|\{|\}|[ \t]*#|\]/).lookBehindToAvoid(/\\/)
    command_continuation     = lookBehindToAvoid(/ |\t|;|\||&|\n|\{|#/)
    unquoted_string_end      = lookAheadFor(/ |\t|;|\||&|$|\n|\)|\`/)
    argument_end             = lookAheadFor(/ |\t|;|\||&|$|\n|\)|\`/)
    invalid_literals         = Regexp.quote(@tokens.representationsThat(:areInvalidLiterals).join(""))
    valid_literal_characters = Regexp.new("[^ \t\n#{invalid_literals}]+")
    any_builtin_name         = @tokens.representationsThat(:areBuiltInCommands).map{ |value| Regexp.quote(value) }.join("|")
    any_builtin_name         = Regexp.new("(?:#{any_builtin_name})(?!\/)")
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
                |value| value + '\b(?!\/)'
            # "OR" join
            }.join("|")
        )
    )
    
    grammar[:keyword] = [
        Pattern.new(
            match: /(?<=^|;|&| |\t)(?:#{@tokens.representationsThat(:areControlFlow).join("|")})(?= |\t|;|&|$)/,
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
    unquoted_command_prefix = generateUnquotedArugment["entity.name.function.call entity.name.command"]
    grammar[:start_of_double_quoted_command_name] = Pattern.new(
        tag_as: "meta.statement.command.name.quoted string.quoted.double punctuation.definition.string.begin entity.name.function.call entity.name.command",
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
        tag_as: "meta.statement.command.name.quoted string.quoted.single punctuation.definition.string.begin entity.name.function.call entity.name.command",
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
        tag_content_as: "meta.statement.command.name.continuation string.quoted.double entity.name.function.call entity.name.command",
        start_pattern: Pattern.new(
            Pattern.new(
                /\G/
            ).lookBehindFor(/"/)
        ),
        end_pattern: Pattern.new(
            match: "\"",
            tag_as: "string.quoted.double punctuation.definition.string.end.shell entity.name.function.call entity.name.command",
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
        tag_content_as: "meta.statement.command.name.continuation string.quoted.single entity.name.function.call entity.name.command",
        start_pattern: Pattern.new(
            Pattern.new(
                /\G/
            ).lookBehindFor(/'/)
        ),
        end_pattern: Pattern.new(
            match: "\'",
            tag_as: "string.quoted.single punctuation.definition.string.end.shell entity.name.function.call entity.name.command",
        ),
    )
    
    grammar[:basic_command_name] = Pattern.new(
        tag_as: "meta.statement.command.name.basic",
        match: Pattern.new(
            Pattern.new(
                possible_command_start
            ).then(
                modifier.or(
                    tag_as: "entity.name.function.call entity.name.command",
                    match: lookAheadToAvoid(/"|'|\\\n?$/).then(/[^!'" \t\n\r]+?/), # start of unquoted command
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
                lookAheadFor(/ |\t/).or(command_end)
            )
        ),
    )
    grammar[:start_of_command] = Pattern.new(
        std_space.then(
            possible_command_start.lookAheadToAvoid(line_continuation) # avoid line exscapes
        )
    )
    
    grammar[:argument_context] = [
        generateUnquotedArugment["string.unquoted.argument"],
        :normal_statement_context,
    ]
    grammar[:argument] = PatternRange.new(
        tag_as: "meta.argument",
        start_pattern: Pattern.new(/[ \t]++/).then(possible_argument_start),
        end_pattern: unquoted_string_end,
        includes: [
            :argument_context,
            :line_continuation,
        ]
    )
    grammar[:option] = PatternRange.new(
        tag_content_as: "string.unquoted.argument constant.other.option",
        start_pattern: Pattern.new(  
            Pattern.new(/[ \t]++/).then(
                match: /-/,
                tag_as: "string.unquoted.argument constant.other.option.dash"
            ).then(
                match: basic_possible_command_start,
                tag_as: "string.unquoted.argument constant.other.option",
            )
        ),
        end_pattern: lookAheadFor(/[ \t]/).or(command_end),
        includes: [
            :option_context,
        ]
    )
    grammar[:simple_options] = zeroOrMoreOf(
        Pattern.new(/[ \t]++/).then(
            match: /\-/,
            tag_as: "string.unquoted.argument constant.other.option.dash"
        ).then(
            match: /\w+/,
            tag_as: "string.unquoted.argument constant.other.option"
        )
    )
    keywords = @tokens.representationsThat(:areShellReservedWords, :areNotModifiers)
    keyword_patterns = /#{keywords.map { |each| each+'\W|'+each+'\$' } .join('|')}/
    control_prefix_commands = @tokens.representationsThat(:areControlFlow, :areFollowedByACommand)
    valid_after_patterns = /#{control_prefix_commands.map { |each| '^'+each+' | '+each+' |\t'+each+' ' } .join('|')}/
    grammar[:normal_statement_inner] = [
            :case_pattern,
            :function_definition,
            :assignment,
            
            # 
            # Command Statement
            # 
            PatternRange.new(
                tag_as: "meta.statement.command",
                start_pattern: grammar[:start_of_command],
                end_pattern: command_end,
                includes: [
                    # 
                    # Command Name Range
                    # 
                    PatternRange.new(
                        tag_as: "meta.statement.command.name",
                        start_pattern: Pattern.new(/\G/,),
                        end_pattern: argument_end,
                        includes: [
                            # 
                            # builtin commands
                            # 
                            :modifiers, # TODO: eventually this one thing shouldnt be here
                            
                            Pattern.new(
                                match: any_builtin_control_flow,
                                tag_as: "entity.name.function.call entity.name.command keyword.control.$match",
                            ),
                            Pattern.new(
                                match: any_builtin_name,
                                tag_as: "entity.name.function.call entity.name.command support.function.builtin",
                            ),
                            :variable,
                            
                            # 
                            # unquoted parts of a command name
                            # 
                            Pattern.new(
                                lookBehindFor(/\G|'|"|\}|\)/).then(
                                    tag_as: "entity.name.function.call entity.name.command",
                                    match: /[^ \n\t\r"'=;#$!&\|`\)\{]+/,
                                ),
                            ),
                            
                            # 
                            # any quotes within a command name
                            # 
                            PatternRange.new(
                                start_pattern: Pattern.new(
                                    Pattern.new(
                                        Pattern.new(/\G/).or(command_continuation)
                                    ).then(
                                        maybe(
                                            match: /\$/,
                                            tag_as: "meta.statement.command.name.quoted punctuation.definition.string entity.name.function.call entity.name.command",
                                        ).then(
                                            reference: "start_quote",
                                            match: Pattern.new(
                                                Pattern.new(
                                                    tag_as: "meta.statement.command.name.quoted string.quoted.double punctuation.definition.string.begin entity.name.function.call entity.name.command",
                                                    match: /"/
                                                ).or(
                                                    tag_as: "meta.statement.command.name.quoted string.quoted.single punctuation.definition.string.begin entity.name.function.call entity.name.command",
                                                    match: /'/,
                                                )
                                            )
                                        )
                                    )
                                ),
                                end_pattern: lookBehindToAvoid(/\G/).lookBehindFor(matchResultOf("start_quote")),
                                includes: [
                                    :continuation_of_single_quoted_command_name,
                                    :continuation_of_double_quoted_command_name,
                                ],
                            ),
                            :line_continuation,
                        ],
                    ),
                    
                    # 
                    # everything else after the command name
                    # 
                    :line_continuation,
                    :option,
                    :argument,
                    # :custom_commands,
                    :statement_context,
                    :string,
                ],
            ),
            :line_continuation,
            :normal_statement_context,
        ]
    grammar[:case_pattern_context] = [
            Pattern.new(
                match: /\*/,
                tag_as: "variable.language.special.quantifier.star keyword.operator.quantifier.star punctuation.definition.arbitrary-repetition punctuation.definition.regex.arbitrary-repetition"
            ),
            Pattern.new(
                match: /\+/,
                tag_as: "variable.language.special.quantifier.plus keyword.operator.quantifier.plus punctuation.definition.arbitrary-repetition punctuation.definition.regex.arbitrary-repetition"
            ),
            Pattern.new(
                match: /\?/,
                tag_as: "variable.language.special.quantifier.question keyword.operator.quantifier.question punctuation.definition.arbitrary-repetition punctuation.definition.regex.arbitrary-repetition"
            ),
            Pattern.new(
                match: /@/,
                tag_as: "variable.language.special.at keyword.operator.at punctuation.definition.regex.at",
            ),
            Pattern.new(
                match: /\|/,
                tag_as: "keyword.operator.orvariable.language.special.or keyword.operator.alternation.ruby punctuation.definition.regex.alternation punctuation.separator.regex.alternation"
            ),
            PatternRange.new(
                tag_as: "meta.parenthese",
                start_pattern: Pattern.new(
                    match: /\(/,
                    tag_as: "punctuation.definition.group punctuation.definition.regex.group",
                ),
                end_pattern: Pattern.new(
                    match: /\)/,
                    tag_as: "punctuation.definition.group punctuation.definition.regex.group",
                ),
                includes: [
                    :case_pattern_context,
                ],
            ),
            PatternRange.new(
                tag_as: "string.regexp.character-class",
                start_pattern: Pattern.new(
                    match: /\[/,
                    tag_as: "punctuation.definition.character-class",
                ),
                end_pattern: Pattern.new(
                    match: /\]/,
                    tag_as: "punctuation.definition.character-class",
                ),
                includes: [
                    Pattern.new(
                        match: /\\./,
                        tag_as: "constant.character.escape.shell",
                    ),
                ],
            ),
            :string,
            Pattern.new(
                match: /[^) \t\n\[\?\*\|\@]/,
                tag_as: "string.unquoted.pattern string.regexp.unquoted",
            ),
        ]
    grammar[:case_pattern] = PatternRange.new(
        tag_as: "meta.case",
        start_pattern: Pattern.new(
            Pattern.new(
                tag_as: "keyword.control.case",
                match: /\bcase\b/,
            ).then(std_space).then(
                match:/.+/, # TODO: this could be a problem for inline case statements
                includes: [
                    :initial_context
                ],
            ).then(std_space).then(
                match: /\bin\b/,
                tag_as: "keyword.control.in",
            )
        ),
        end_pattern: Pattern.new(
            tag_as: "keyword.control.esac",
            match: /\besac\b/
        ),
        includes: [
            :comment,
            # hardcode-match default case
            std_space.then(
                match: /\* *\)/,
                tag_as: "keyword.operator.pattern.case.default",
            ),
            # pattern part, everything before ")"
            PatternRange.new(
                tag_as: "meta.case.entry.pattern",
                start_pattern: lookBehindToAvoid(/\)/).lookAheadToAvoid(std_space.then(/esac\b|$/)),
                end_pattern: lookAheadFor(/\besac\b/).or(
                    match: /\)/,
                    tag_as: "keyword.operator.pattern.case",
                ),
                includes: [
                    :case_pattern_context,
                ],
            ),
            # after-pattern part 
            PatternRange.new(
                tag_as: "meta.case.entry.body",
                start_pattern: lookBehindFor(/\)/),
                end_pattern: Pattern.new(
                    Pattern.new(
                        match: /;;/,
                        tag_as: "punctuation.terminator.statement.case",
                    ).or(
                        lookAheadFor(/\besac\b/)
                    )
                ),
                includes: [
                    :normal_statement_inner,
                    :initial_context,
                ],
            ),
        ],
    )
    grammar[:normal_statement] = PatternRange.new(
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
        includes: [ :normal_statement_inner ]
        
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
            start_pattern: lookBehindToAvoid(/[^ \t]/).then(
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
        generateVariable(/[-*#?$!0_]/, "variable.language.special"),
        # positional but has {}'s
        PatternRange.new(
            tag_content_as: "meta.parameter-expansion",
            start_pattern: Pattern.new(
                    match: Pattern.new(
                        match: /\$/,
                        tag_as: "punctuation.definition.variable variable.parameter.positional"
                    ).then(
                        match: /\{/,
                        tag_as: "punctuation.section.bracket.curly.variable.begin punctuation.definition.variable variable.parameter.positional",
                    ).then(std_space).lookAheadFor(/\d/)
                ),
            end_pattern: Pattern.new(
                    match: /\}/,
                    tag_as: "punctuation.section.bracket.curly.variable.end punctuation.definition.variable variable.parameter.positional",
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
                Pattern.new(
                    match: /[0-9]+/,
                    tag_as: "variable.parameter.positional",
                ),
                Pattern.new(
                    match: variable_name,
                    tag_as: "variable.other.normal",
                ),
                :variable,
                :string,
            ]
        ),
        # Normal varible {}'s
        PatternRange.new(
            tag_content_as: "meta.parameter-expansion",
            start_pattern: Pattern.new(
                    match: Pattern.new(
                        match: /\$/,
                        tag_as: "punctuation.definition.variable"
                    ).then(
                        match: /\{/,
                        tag_as: "punctuation.section.bracket.curly.variable.begin punctuation.definition.variable",
                        
                    )
                ),
            end_pattern: Pattern.new(
                    match: /\}/,
                    tag_as: "punctuation.section.bracket.curly.variable.end punctuation.definition.variable",
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
                Pattern.new(
                    match: variable_name,
                    tag_as: "variable.other.normal",
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
                                match: /[^"']+?/, # can create problems
                                reference: "delimiter",
                                tag_as: "punctuation.definition.string.heredoc",
                            ).lookAheadFor(/\s|;|&|<|"|'/).matchResultOf(
                                "start_quote"
                            ).then(
                                match: /.*/,
                                includes: [
                                    :normal_statement_context,
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
                                match: /[^"']+?/, # can create problems
                                reference: "delimiter",
                                tag_as: "punctuation.definition.string.heredoc",
                            ).lookAheadFor(/\s|;|&|<|"|'/).matchResultOf(
                                "start_quote"
                            ).then(
                                match: /.*/,
                                includes: [
                                    :normal_statement_context,
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
                                match: /[^"']+?/, # can create problems
                                reference: "delimiter",
                                tag_as: "punctuation.definition.string.heredoc",
                            ).lookAheadFor(/\s|;|&|<|"|'/).then(
                                match: /.*/,
                                includes: [
                                    :normal_statement_context,
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
                                match: /[^"']+?/, # can create problems
                                reference: "delimiter",
                                tag_as: "punctuation.definition.string.heredoc",
                            ).lookAheadFor(/\s|;|&|<|"|'/).then(
                                match: /.*/,
                                includes: [
                                    :normal_statement_context,
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
