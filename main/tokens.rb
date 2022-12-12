require "walk_up"
require_relative walk_up_until("paths.rb")
require_relative PathFor[:textmate_tools]

# 
# Create tokens
#
# (these are from C++)
tokens = [
    { representation: '|' , areInvalidLiterals: true },
    { representation: '&' , areInvalidLiterals: true },
    { representation: ';' , areInvalidLiterals: true },
    { representation: '<' , areInvalidLiterals: true },
    { representation: '>' , areInvalidLiterals: true },
    { representation: '(' , areInvalidLiterals: true },
    { representation: ')' , areInvalidLiterals: true },
    { representation: '$' , areInvalidLiterals: true },
    { representation: '`' , areInvalidLiterals: true },
    { representation: '\\', areInvalidLiterals: true },
    { representation: '"' , areInvalidLiterals: true },
    { representation: '\'', areInvalidLiterals: true },
    { representation: "function" , areNonCommands: true, },
    { representation: "export"   , areNonCommands: true, },
    { representation: "select"   , areNonCommands: true, },
    { representation: "case"     , areNonCommands: true, },
    { representation: "do"       , areNonCommands: true, },
    { representation: "done"     , areNonCommands: true, },
    { representation: "elif"     , areNonCommands: true, },
    { representation: "else"     , areNonCommands: true, },
    { representation: "esac"     , areNonCommands: true, },
    { representation: "fi"       , areNonCommands: true, },
    { representation: "for"      , areNonCommands: true, },
    { representation: "if"       , areNonCommands: true, },
    { representation: "in"       , areNonCommands: true, },
    { representation: "then"     , areNonCommands: true, },
    { representation: "until"    , areNonCommands: true, },
    { representation: "while"    , areNonCommands: true, },
    { representation: "alias"    , areNonCommands: true, },
    { representation: "bg"       , },
    { representation: "command"  , },
    { representation: "false"    , },
    { representation: "fc"       , },
    { representation: "fg"       , },
    { representation: "getopts"  , },
    { representation: "hash"     , },
    { representation: "jobs"     , },
    { representation: "kill"     , },
    { representation: "newgrp"   , },
    { representation: "read"     , },
    { representation: "true"     , },
    { representation: "umask"    , },
    { representation: "unalias"  , },
    { representation: "wait"     , },
]

# automatically add some adjectives (functional adjectives)
@tokens = TokenHelper.new tokens, for_each_token: ->(each) do 
    # isSymbol, isWordish
    if each[:representation] =~ /[a-zA-Z0-9_]/
        each[:isWordish] = true
    else
        each[:isSymbol] = true
    end
    # isWord
    if each[:representation] =~ /\A[a-zA-Z_][a-zA-Z0-9_]*\z/
        each[:isWord] = true
    end
end