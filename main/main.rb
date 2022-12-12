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
    grammar.import(PathFor[:pattern]["numeric_literal"])

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
            :boolean,
            :numeric_literal,
            :pipeline,
            :statement_seperator,
            :logical_expression_double,
            :logical_expression_single,
            :misc_ranges,
            :loop,
            :string,
            :'function-definition',
            :variable,
            :interpolation,
            :heredoc,
            :herestring,
            :redirection,
            :pathname,
            :keyword,
            :alias_statement,
            :assignment,
            :custom_commands,
            :command_call,
            :support,
        ]
    grammar[:boolean] = Pattern.new(
            match: /\b(?:true|false)\b/,
            tag_as: "constant.language.$match"
        )
    grammar[:command_context] = [
            :comment,
            :pipeline,
            :statement_seperator,
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
            :line_continuation,
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
    grammar[:variable_assignment_context] = [
            :$initial_context
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
    
    part_of_a_variable = /[a-zA-Z_][a-zA-Z_0-9]*/
    # this is really useful for keywords. eg: variableBounds[/new/] wont match "newThing" or "thingnew"
    variableBounds = ->(regex_pattern) do
        lookBehindToAvoid(@standard_character).then(regex_pattern).lookAheadToAvoid(@standard_character)
    end
    variable_name = variableBounds[part_of_a_variable]
    
    std_space = Pattern.new(/\s*+/)
    
    # 
    # comments
    #
    grammar[:comment] = lookBehindFor(/^|\s/).then(
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
    # NOTE: this is not yet actually used
    function_definition_start_pattern = std_space.then(
            # this is the case with the function keyword
            Pattern.new(
                match: /\bfunction /,
                tag_as: "storage.type.function"
            ).then(std_space).then(
                variable_name
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
            variable_name.then(
                std_space
            ).then(
                match: /\(/,
                tag_as: "punctuation.definition.arguments",
            ).then(std_space).then(
                match: /\)/,
                tag_as: "punctuation.definition.arguments",
            )
        )
    grammar[:assignment] = PatternRange.new(
        tag_as: "meta.expression.assignment",
        start_pattern: assignment_start = std_space.then(
                match: variable_name,
                tag_as: "variable.other.assignment",
            ).then(
                Pattern.new(
                    match: /\=/,
                    tag_as: "keyword.operator.assignment",
                ).or(
                    match: /\+\=/,
                    tag_as: "keyword.operator.assignment.compound",
                )
            ),
        end_pattern: assignment_end = grammar[:statement_seperator].or(lookAheadFor(/ /)),
        includes: [ :variable_assignment_context ]
    )
    grammar[:alias_statement] = PatternRange.new(
        tag_as: "meta.expression.assignment",
        start_pattern:  Pattern.new(
                match: /alias/,
                tag_as: "storage.type.alias"
            ).then(@spaces).then(assignment_start),
        end_pattern: assignment_end,
        includes: [ :variable_assignment_context ]
    )
    
    possible_pre_command_characters = /(?:^|;|\||&|!|\(|\{|\`)/
    possible_command_start   = lookAheadToAvoid(/(?:!|%|&|\||\(|\{|\[|<|>|#|\n|$|\$|;)/)
    command_end              = lookAheadFor(/;|\||&|$|\n|\)|\`|\}|\{|\}|#|\]/).lookBehindToAvoid(/\\/)
    unquoted_string_end      = lookAheadFor(/\s|;|\||&|$|\n|\)|\`/)
    invalid_literals         = Regexp.quote(@tokens.representationsThat(:areInvalidLiterals).join(""))
    valid_literal_characters = Regexp.new("[^\s#{invalid_literals}]+")
    
    grammar[:command_name] = PatternRange.new(
        tag_as: "entity.name.command",
        start_pattern: std_space.then(possible_command_start),
        end_pattern: lookAheadFor(@space).or(command_end),
        includes: [
            :custom_command_names,
            :command_context,
        ]
    )
    grammar[:argument] = PatternRange.new(
        tag_as: "meta.argument",
        start_pattern: Pattern.new(/\s++/).then(possible_command_start),
        end_pattern: unquoted_string_end,
        includes: [
            :command_context,
            Pattern.new(
                tag_as: "string.unquoted.argument",
                match: valid_literal_characters,
                includes: [
                    # wildcard
                    Pattern.new(
                        match: /\*/,
                        tag_as: "variable.language.special.wildcard"
                    ),
                ]
            ),
        ]
    )
    grammar[:option] = PatternRange.new(
        tag_content_as: "string.unquoted.argument constant.other.option",
        start_pattern: Pattern.new(  
            Pattern.new(/\s++/).then(
                match: /-/,
                tag_as: "string.unquoted.argument constant.other.option.dash"
            ).then(
                match: possible_command_start,
                tag_as: "string.unquoted.argument constant.other.option",
            )
        ),
        end_pattern: lookAheadFor(@space).or(command_end),
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
    keywords = @tokens.representationsThat(:areNonCommands)
    keyword_patterns = /#{keywords.map { |each| each+'\W|'+each+'\$' } .join('|')}/
    grammar[:command_call] = PatternRange.new(
        zeroLengthStart?: true,
        tag_as: "meta.statement",
        start_pattern: lookBehindFor(possible_pre_command_characters).then(std_space).lookAheadToAvoid(keyword_patterns),
        end_pattern: command_end,
        includes: [
            :option,
            :argument,
            :custom_commands,
            :command_name,
            :command_context
        ]
    )
    grammar[:custom_commands] = [
        # Note:
        #   this sed does not cover all possible cases, it only covers the most likely case
        #   in the event of a more complicated case, it falls back on tradidional command highlighting
        grammar[:sed_command] = Pattern.new(
            Pattern.new(
                match: /\bsed\b/,
                tag_as: "support.function.builtin",
            ).then(
                grammar[:simple_options]
            ).then(@spaces).then(
                match: /'s\//,
                tag_as: "punctuation.section.regexp",
            ).zeroOrMoreOf(
                match: Pattern.new(/\\./).or(/[^\/]/), # find
                includes: [ :regexp ],
            ).then(
                match: /\//,
                tag_as: "punctuation.section.regexp",
            ).zeroOrMoreOf(
                match: Pattern.new(/\\./).or(/[^\/]/), # replace
                includes: [ :regexp ],
            ).then(
                match: /\/\w{0,4}\'/,
                tag_as: "punctuation.section.regexp",
            )
        ),
    ]
    grammar[:custom_command_names] = [
        # legacy built-in commands
        {
            "match": "(?<=^|;|&|\\s)(?:alias|bg|bind|break|builtin|caller|cd|command|compgen|complete|dirs|disown|echo|enable|eval|exec|exit|false|fc|fg|getopts|hash|help|history|jobs|kill|let|logout|popd|printf|pushd|pwd|read|readonly|set|shift|shopt|source|suspend|test|times|trap|true|type|ulimit|umask|unalias|unset|wait)(?=\\s|;|&|$)",
            "name": "support.function.builtin.shell"
        }        
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
        includes: grammar[:logical_expression_context]
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
        includes: grammar[:logical_expression_context]
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
                    match: /\(/
                ),
            end_pattern: Pattern.new(
                    tag_as: "punctuation.definition.subshell",
                    match: /\)/
                ),
            includes: [
                :$initial_context,
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
                :$initial_context
            ]
        ),
    ]
    
    grammar[:regex_comparison] = Pattern.new(
        Pattern.new(
            tag_as: "keyword.operator.logical",
            match: /\=~/,
        ).then(
            @spaces
        ).then(
            match: /[^ ]*/,
            includes: [
                :variable,
                :regexp
            ]
        )
    )
    
    def generateVariable(regex_after_dollarsign, tag)
        Pattern.new(
            match: Pattern.new(
                match: /\$/,
                tag_as: "punctuation.definition.variable #{tag}"
            ).then(
                match: Pattern.new(regex_after_dollarsign).lookAheadFor(/\W/),
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
                {
                    "match": "!|:[-=?]?|\\*|@|\#{1,2}|%{1,2}|/",
                    "name": "keyword.operator.expansion.shell"
                },
                {
                    "captures": {
                        "1": {
                            "name": "punctuation.section.array.shell"
                        },
                        "3": {
                            "name": "punctuation.section.array.shell"
                        }
                    },
                    "match": "(\\[)([^\\]]+)(\\])"
                },
                :variable,
                :string,
            ]
        ),
        # normal variables
        generateVariable(/\w+/, "variable.other.normal")
    ]
    
    # 
    # regex (legacy format, imported from JavaScript regex)
    # 
        grammar[:regexp] = {
            "patterns"=> [
                {
                    "name"=> "punctuation.definition.character-class.named.regexp",
                    "match"=> "\\[\\[:\\w+:\\]\\]"
                },
                {
                    "name"=> "keyword.control.anchor.regexp",
                    "match"=> "\\\\[bB]|\\^|\\$"
                },
                {
                    "match"=> "\\\\[1-9]\\d*|\\\\k<([a-zA-Z_$][\\w$]*)>",
                    "captures"=> {
                        "0"=> {
                            "name"=> "keyword.other.back-reference.regexp"
                        },
                        "1"=> {
                            "name"=> "variable.other.regexp"
                        }
                    }
                },
                {
                    "name"=> "keyword.operator.quantifier.regexp",
                    "match"=> "[?+*]|\\{(\\d+,\\d+|\\d+,|,\\d+|\\d+)\\}\\??"
                },
                {
                    "name"=> "keyword.operator.or.regexp",
                    "match"=> "\\|"
                },
                {
                    "name"=> "meta.group.assertion.regexp",
                    "begin"=> "(\\()((\\?=)|(\\?!)|(\\?<=)|(\\?<!))",
                    "beginCaptures"=> {
                        "1"=> {
                            "name"=> "punctuation.definition.group.regexp"
                        },
                        "2"=> {
                            "name"=> "punctuation.definition.group.assertion.regexp"
                        },
                        "3"=> {
                            "name"=> "meta.assertion.look-ahead.regexp"
                        },
                        "4"=> {
                            "name"=> "meta.assertion.negative-look-ahead.regexp"
                        },
                        "5"=> {
                            "name"=> "meta.assertion.look-behind.regexp"
                        },
                        "6"=> {
                            "name"=> "meta.assertion.negative-look-behind.regexp"
                        }
                    },
                    "end"=> "(\\))",
                    "endCaptures"=> {
                        "1"=> {
                            "name"=> "punctuation.definition.group.regexp"
                        }
                    },
                    "patterns"=> [
                        {
                            "include"=> "#regexp"
                        }
                    ]
                },
                {
                    "name"=> "meta.group.regexp",
                    "begin"=> "\\((?:(\\?:)|(?:\\?<([a-zA-Z_$][\\w$]*)>))?",
                    "beginCaptures"=> {
                        "0"=> {
                            "name"=> "punctuation.definition.group.regexp"
                        },
                        "1"=> {
                            "name"=> "punctuation.definition.group.no-capture.regexp"
                        },
                        "2"=> {
                            "name"=> "variable.other.regexp"
                        }
                    },
                    "end"=> "\\)",
                    "endCaptures"=> {
                        "0"=> {
                            "name"=> "punctuation.definition.group.regexp"
                        }
                    },
                    "patterns"=> [
                        {
                            "include"=> "#regexp"
                        }
                    ]
                },
                {
                    "name"=> "constant.other.character-class.set.regexp",
                    "begin"=> "(\\[)(\\^)?",
                    "beginCaptures"=> {
                        "1"=> {
                            "name"=> "punctuation.definition.character-class.regexp"
                        },
                        "2"=> {
                            "name"=> "keyword.operator.negation.regexp"
                        }
                    },
                    "end"=> "(\\])",
                    "endCaptures"=> {
                        "1"=> {
                            "name"=> "punctuation.definition.character-class.regexp"
                        }
                    },
                    "patterns"=> [
                        {
                            "name"=> "constant.other.character-class.range.regexp",
                            "match"=> "(?:.|(\\\\(?:[0-7]{3}|x[0-9A-Fa-f]{2}|u[0-9A-Fa-f]{4}))|(\\\\c[A-Z])|(\\\\.))\\-(?:[^\\]\\\\]|(\\\\(?:[0-7]{3}|x[0-9A-Fa-f]{2}|u[0-9A-Fa-f]{4}))|(\\\\c[A-Z])|(\\\\.))",
                            "captures"=> {
                                "1"=> {
                                    "name"=> "constant.character.numeric.regexp"
                                },
                                "2"=> {
                                    "name"=> "constant.character.control.regexp"
                                },
                                "3"=> {
                                    "name"=> "constant.character.escape.backslash.regexp"
                                },
                                "4"=> {
                                    "name"=> "constant.character.numeric.regexp"
                                },
                                "5"=> {
                                    "name"=> "constant.character.control.regexp"
                                },
                                "6"=> {
                                    "name"=> "constant.character.escape.backslash.regexp"
                                }
                            }
                        },
                        {
                            "include"=> "#regex-character-class"
                        }
                    ]
                },
                {
                    "include"=> "#regex-character-class"
                }
            ]
        }
        grammar[:regex_character_class] = {
            "patterns"=> [
                {
                    "name"=> "constant.other.character-class.regexp",
                    "match"=> "\\\\[wWsSdDtrnvf]|\\."
                },
                {
                    "name"=> "constant.character.numeric.regexp",
                    "match"=> "\\\\([0-7]{3}|x[0-9A-Fa-f]{2}|u[0-9A-Fa-f]{4})"
                },
                {
                    "name"=> "constant.character.control.regexp",
                    "match"=> "\\\\c[A-Z]"
                },
                {
                    "name"=> "constant.character.escape.backslash.regexp",
                    "match"=> "\\\\."
                }
            ]
        }

#
# Save
#
name = "shell"
grammar.save_to(
    syntax_name: name,
    syntax_dir: "./autogenerated",
    tag_dir: "./autogenerated",
)