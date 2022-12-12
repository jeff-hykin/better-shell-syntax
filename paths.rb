require 'json'
require 'yaml'
require 'fileutils'
require 'pathname'

PathFor = {
    root: __dir__,
    syntax:                 File.join(__dir__, "autogenerated"    , "shell.tmLanguage.json"    ),
    modified_original:      File.join(__dir__, "main"             , "modified.tmlanguage.json" ),
    textmate_tools:         File.join(__dir__, "main"             , "textmate_tools.rb"        ),
    linter:                 File.join(__dir__, "lint"             , "index.js"                 ),
    fixtures:               File.join(__dir__, "language_examples",                            ),
    
    pattern:                ->(pattern_file) { File.join(__dir__, "main", "patterns", pattern_file) },
}