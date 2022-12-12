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
            # :custom_commands,
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
            :initial_context
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
                Pattern.new(
                    match: variable_name,
                    tag_as: "variable.other.assignment",
                ).maybe(
                    Pattern.new(
                        match: "[",
                        tag_as: "punctuation.definition.array.access",
                    ).then(
                        match: variable_name.or("@"),
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
    any_builtin_name         = @tokens.representationsThat(:areBuiltInCommands).map{ |value| Regexp.quote(value) }.join("|")
    any_builtin_name         = Regexp.new("(?:#{any_builtin_name})")
    any_builtin_name         = variableBounds[any_builtin_name]
    
    grammar[:command_name] = PatternRange.new(
        tag_as: "entity.name.command",
        start_pattern: std_space.then(possible_command_start),
        end_pattern: lookAheadFor(@space).or(command_end),
        includes: [
            Pattern.new(
                match: any_builtin_name,
                tag_as: "support.function.builtin",
            ),
            # :custom_command_names,
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
    keywords = @tokens.representationsThat(:areShellReservedWords)
    keyword_patterns = /#{keywords.map { |each| each+'\W|'+each+'\$' } .join('|')}/
    grammar[:command_call] = PatternRange.new(
        zeroLengthStart?: true,
        tag_as: "meta.statement",
        start_pattern: lookBehindFor(possible_pre_command_characters).then(std_space).lookAheadToAvoid(keyword_patterns),
        end_pattern: command_end,
        includes: [
            :option,
            :argument,
            # :custom_commands,
            :command_name,
            :command_context
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
    # regex (legacy format, imported from JavaScript regex)
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