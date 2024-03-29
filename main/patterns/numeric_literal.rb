# frozen_string_literal: true
require 'ruby_grammar_builder'
require 'walk_up'
require_relative walk_up_until("paths.rb")



export = Grammar.new_exportable_grammar
export.external_repos = [ # patterns that are imported
]
export.exports = [ # patterns that are exported
    :numeric_literal,
]




# 
# bet you didn't think number literals were this complicated lol
# 
def generateNumericLiteral(allow_user_defined_literals: false, separator:"'")
    # both C and C++ treat any sequence of digits, letter, periods, and valid separators
    # as a single numeric constant even if such a sequence forms no valid
    # constant/literal
    # additionally +- are part of the sequence when immediately succeeding e,E,p, or P.
    # the outer range pattern does not attempt to actually process the numbers
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
        match: lookBehindToAvoid(/\w/).then(/\.?\d/).zeroOrMoreOf(valid_character),
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

# create/export the numeric literal
export[:numeric_literal] = generateNumericLiteral()