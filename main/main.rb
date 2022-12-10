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
# grammar = Grammar.fromTmLanguage("./original.tmLanguage.json")
grammar = Grammar.new(
    name: "Shell",
    scope_name: "source.shell",
    fileTypes: [
        "sh",
        "zsh",
        "bash",
    ],
    version: "",
)

# 
#
# Setup Grammar
#
# 
    grammar[:$initial_context] = [
        :comments,
        :string,
        :variable,
        # (add more stuff here) (variables, strings, numbers)
    ]

# 
# Helpers
# 
    # @space
    # @spaces
    # @digit
    # @digits
    # @standard_character
    # @word
    # @word_boundary
    # @white_space_start_boundary
    # @white_space_end_boundary
    # @start_of_document
    # @end_of_document
    # @start_of_line
    # @end_of_line
    part_of_a_variable = /[a-zA-Z_][a-zA-Z_0-9]*/
    # this is really useful for keywords. eg: variableBounds[/new/] wont match "newThing" or "thingnew"
    variableBounds = ->(regex_pattern) do
        lookBehindToAvoid(@standard_character).then(regex_pattern).lookAheadToAvoid(@standard_character)
    end
    variable = variableBounds[part_of_a_variable]

# 
# contexts
# 
    # anything
        # assignment
        # statement
        # subshell
        # command
    # command_only
        # end: teminator or non backslash newline
    # interpolation
# 
# overview
# 
    # comment
        # hash bang
    # variable assignment
    #     local
    #     readonly
    #     export
    #     (etc)
    # alias
    # function
    # if statement
    # case statement
        # case "$1" in
        # start | up)
        #     vagrant up
        #     ;;
        # *)
        #     echo "Usage: $0 {start|stop|ssh}"
        #     ;;
        # esac
    # for statement
    # while statement
    # until statement
    # sub shell (curly braces)
    # command
        # special commands
            # []'s
            # [[]]
                # file conditions
                    # [[ -e FILE ]] 	Exists
                    # [[ -r FILE ]] 	Readable
                    # [[ -h FILE ]] 	Symlink
                    # [[ -d FILE ]] 	Directory
                    # [[ -w FILE ]] 	Writable
                    # [[ -s FILE ]] 	Size is > 0 bytes
                    # [[ -f FILE ]] 	File
                    # [[ -x FILE ]] 	Executable
                    # [[ FILE1 -nt FILE2 ]] 	1 is more recent than 2
                    # [[ FILE1 -ot FILE2 ]] 	2 is more recent than 1
                    # [[ FILE1 -ef FILE2 ]] 	Same files
                # other conditions
                    # [[ -z STRING ]] 	Empty string
                    # [[ -n STRING ]] 	Not empty string
                    # [[ STRING == STRING ]] 	Equal
                    # [[ STRING != STRING ]] 	Not Equal
                    # [[ NUM -eq NUM ]] 	Equal
                    # [[ NUM -ne NUM ]] 	Not equal
                    # [[ NUM -lt NUM ]] 	Less than
                    # [[ NUM -le NUM ]] 	Less than or equal
                    # [[ NUM -gt NUM ]] 	Greater than
                    # [[ NUM -ge NUM ]] 	Greater than or equal
                    # [[ STRING =~ STRING ]] 	Regexp
                    # [[ -o noclobber ]] 	If OPTIONNAME is enabled
                    # [[ ! EXPR ]] 	Not
                    # [[ X && Y ]] 	And
                    # [[ X || Y ]] 	Or
            # (())
                # (( NUM < NUM )) 	Numeric conditions
            # !
            # builtin
            # sudo (not actually special but first non -- arg is known as a command name)
        # argument
            # tilde as home
            # star as globbing
            # brace expansion
            # unquoted string
            # interpolated variable
                # simple case: $name
                # special vars
                # 	Number of arguments
                    # $* 	All positional arguments (as a single word)
                    # $@ 	All positional arguments (as separate strings)
                    # $1 	First argument
                    # $_ 	Last argument of the previous command
                    # $?
                    # $$
                    # (probably more)
                # expansion:
                    # echo ${name}
                    # echo ${name/J/j}    #=> "john" (substitution)
                    # echo ${name:0:2}    #=> "Jo" (slicing)
                    # echo ${name::2}     #=> "Jo" (slicing)
                    # echo ${name::-1}    #=> "Joh" (slicing)
                    # echo ${name:(-1)}   #=> "n" (slicing from right)
                    # echo ${name:(-2):1} #=> "h" (slicing from right)
                    # echo ${food:-Cake}  #=> $food or "Cake"
                # substitution
                    # ${FOO%suffix} 	Remove suffix
                    # ${FOO#prefix} 	Remove prefix
                    # ${FOO%%suffix} 	Remove long suffix
                    # ${FOO##prefix} 	Remove long prefix
                    # ${FOO/from/to} 	Replace first match
                    # ${FOO//from/to} 	Replace all
                    # ${FOO/%from/to} 	Replace suffix
                    # ${FOO/#from/to}
                # substring
                    # ${FOO:0:3} 	Substring (position, length)
                    # ${FOO:(-3):3} 	Substring from the right

            # interpolated command
            # arithmetic (())
            # single quoted
            # double quoted
                # interpolation
                # backticks
            # heredocs
                # cat <<EOF
                #     echo "$HOME"
                #     echo "\$HOME"
                # EOF
                # cat <<EOF > /tmp/foo
                #     echo "$HOME"
                #     echo "\$HOME"
                # EOF
                # cat <<-EOF > /tmp/foo
                #     echo "$HOME"
                #     echo "\$HOME"
                # EOF
                # cat <<-'EOF' > /tmp/foo
                #     echo "$HOME"
                #     echo "\$HOME"
                # EOF
        # redirection
            # python hello.py > output.txt   # stdout to (file)
            # python hello.py >> output.txt  # stdout to (file), append
            # python hello.py 2> error.log   # stderr to (file)
            # python hello.py 2>&1           # stderr to stdout
            # python hello.py 2>/dev/null    # stderr to (null)
            # python hello.py &>/dev/null    # stdout and stderr to (null)
            # python hello.py < foo.txt      # feed foo.txt to stdin for python
            # diff <(ls -r) <(ls)            # Compare two stdout without files
        # teminator
            # pipe
            # semicolon
            # &&
            # ||
        # background task (&)
    # arrays
        # Fruits=('Apple' 'Banana' 'Orange')
        # Fruits[0]="Apple"
        # Fruits[1]="Banana"
        # Fruits[2]="Orange"
        # Fruits=("${Fruits[@]}" "Watermelon")    # Push
        # Fruits+=('Watermelon')                  # Also Push
        # Fruits=( ${Fruits[@]/Ap*/} )            # Remove by regex match
        # unset Fruits[2]                         # Remove one item
        # Fruits=("${Fruits[@]}")                 # Duplicate
        # Fruits=("${Fruits[@]}" "${Veggies[@]}") # Concatenate
        # lines=(`cat "logfile"`)                 # Read from file
        # echo ${Fruits[0]}           # Element #0
        # echo ${Fruits[-1]}          # Last element
        # echo ${Fruits[@]}           # All elements, space-separated
        # echo ${#Fruits[@]}          # Number of elements
        # echo ${#Fruits}             # String length of the 1st element
        # echo ${#Fruits[3]}          # String length of the Nth element
        # echo ${Fruits[@]:3:2}       # Range (from position 3, length 2)
        # echo ${!Fruits[@]}          # Keys of all elements, space-separated
    # bash $""
    
    
    
# 
# implementation
# 
    # 
    # edgecases
    # 
        # hashbang
        # sub shell (curly braces)
        # comment
    # 
    # assignment
    # 
        # variable assignment
        #     local
        #     readonly
        #     export
        #     (etc)
        # alias
        # function
    # 
    # statements
    # 
        command_terminator = Pattern.new(match: /(?<!\\)$|;/, tag_as: "punctuation.teminator")
        # if statement
            grammar[:if_statement] = PatternRange.new(
                start_pattern: Pattern.new(
                    match: variableBounds[/if/],
                ),
                end_pattern: Pattern.new(
                    match: lookBehindFor(/;|^/).then(@spaces).then(variableBounds[/fi/]),
                ),
                includes: [
                    PatternRange.new(
                        start_pattern: /\G/,
                        end_pattern: command_terminator,
                        includes: [
                            :command,
                        ]
                    ),
                    Pattern.new(match: variableBounds[/then/]),
                    PatternRange.new(
                        start_pattern: command_terminator,
                        end_pattern: command_terminator,
                        includes: [
                            :command,
                        ]
                    ),
                ]
            )
        # case statement
            # case "$1" in
            # start | up)
            #     vagrant up
            #     ;;
            # *)
            #     echo "Usage: $0 {start|stop|ssh}"
            #     ;;
            # esac
        # for statement
        # while statement
        # until statement
    # 
    # commands
    # 
        command_terminator= /;|&&|\|\||\||$/
        grammar[:command] = PatternRange.new(
            start_pattern: lookAheadFor(/\G/), # starts immediately
            end_pattern: lookAheadFor(command_terminator),
            includes: [
                # whole command, but know to be a quote command
                PatternRange.new(
                    start_pattern: Pattern.new(/"/),
                    end_pattern: lookAheadFor(command_terminator),
                    includes: [
                        # rest of quote
                        PatternRange.new(
                            start_pattern: /\G/,
                            end_pattern: /"/,
                        ),
                        # 
                    ],
                ),
            ]
        )
        # special commands
            # []'s
            # [[]]
                # file conditions
                    # [[ -e FILE ]] 	Exists
                    # [[ -r FILE ]] 	Readable
                    # [[ -h FILE ]] 	Symlink
                    # [[ -d FILE ]] 	Directory
                    # [[ -w FILE ]] 	Writable
                    # [[ -s FILE ]] 	Size is > 0 bytes
                    # [[ -f FILE ]] 	File
                    # [[ -x FILE ]] 	Executable
                    # [[ FILE1 -nt FILE2 ]] 	1 is more recent than 2
                    # [[ FILE1 -ot FILE2 ]] 	2 is more recent than 1
                    # [[ FILE1 -ef FILE2 ]] 	Same files
                # other conditions
                    # [[ -z STRING ]] 	Empty string
                    # [[ -n STRING ]] 	Not empty string
                    # [[ STRING == STRING ]] 	Equal
                    # [[ STRING != STRING ]] 	Not Equal
                    # [[ NUM -eq NUM ]] 	Equal
                    # [[ NUM -ne NUM ]] 	Not equal
                    # [[ NUM -lt NUM ]] 	Less than
                    # [[ NUM -le NUM ]] 	Less than or equal
                    # [[ NUM -gt NUM ]] 	Greater than
                    # [[ NUM -ge NUM ]] 	Greater than or equal
                    # [[ STRING =~ STRING ]] 	Regexp
                    # [[ -o noclobber ]] 	If OPTIONNAME is enabled
                    # [[ ! EXPR ]] 	Not
                    # [[ X && Y ]] 	And
                    # [[ X || Y ]] 	Or
            # (())
                # (( NUM < NUM )) 	Numeric conditions
            # !
            # builtin
            # sudo (not actually special but first non -- arg is known as a command name)
        # argument
            # tilde as home
            # star as globbing
            # brace expansion
            # unquoted string
            # interpolated variable
                # simple case: $name
                # special vars
                # 	Number of arguments
                    # $* 	All positional arguments (as a single word)
                    # $@ 	All positional arguments (as separate strings)
                    # $1 	First argument
                    # $_ 	Last argument of the previous command
                    # $?
                    # $$
                    # (probably more)
                # expansion:
                    # echo ${name}
                    # echo ${name/J/j}    #=> "john" (substitution)
                    # echo ${name:0:2}    #=> "Jo" (slicing)
                    # echo ${name::2}     #=> "Jo" (slicing)
                    # echo ${name::-1}    #=> "Joh" (slicing)
                    # echo ${name:(-1)}   #=> "n" (slicing from right)
                    # echo ${name:(-2):1} #=> "h" (slicing from right)
                    # echo ${food:-Cake}  #=> $food or "Cake"
                # substitution
                    # ${FOO%suffix} 	Remove suffix
                    # ${FOO#prefix} 	Remove prefix
                    # ${FOO%%suffix} 	Remove long suffix
                    # ${FOO##prefix} 	Remove long prefix
                    # ${FOO/from/to} 	Replace first match
                    # ${FOO//from/to} 	Replace all
                    # ${FOO/%from/to} 	Replace suffix
                    # ${FOO/#from/to}
                # substring
                    # ${FOO:0:3} 	Substring (position, length)
                    # ${FOO:(-3):3} 	Substring from the right

            # interpolated command
            # arithmetic (())
            # single quoted
            # double quoted
                # interpolation
                # backticks
            # heredocs
                # cat <<EOF
                #     echo "$HOME"
                #     echo "\$HOME"
                # EOF
                # cat <<EOF > /tmp/foo
                #     echo "$HOME"
                #     echo "\$HOME"
                # EOF
                # cat <<-EOF > /tmp/foo
                #     echo "$HOME"
                #     echo "\$HOME"
                # EOF
                # cat <<-'EOF' > /tmp/foo
                #     echo "$HOME"
                #     echo "\$HOME"
                # EOF
        # redirection
            # python hello.py > output.txt   # stdout to (file)
            # python hello.py >> output.txt  # stdout to (file), append
            # python hello.py 2> error.log   # stderr to (file)
            # python hello.py 2>&1           # stderr to stdout
            # python hello.py 2>/dev/null    # stderr to (null)
            # python hello.py &>/dev/null    # stdout and stderr to (null)
            # python hello.py < foo.txt      # feed foo.txt to stdin for python
            # diff <(ls -r) <(ls)            # Compare two stdout without files
        # teminator
            # pipe
            # semicolon
            # &&
            # ||
    
    # 
    # future
    # 
        # arrays
            # Fruits=('Apple' 'Banana' 'Orange')
            # Fruits[0]="Apple"
            # Fruits[1]="Banana"
            # Fruits[2]="Orange"
            # Fruits=("${Fruits[@]}" "Watermelon")    # Push
            # Fruits+=('Watermelon')                  # Also Push
            # Fruits=( ${Fruits[@]/Ap*/} )            # Remove by regex match
            # unset Fruits[2]                         # Remove one item
            # Fruits=("${Fruits[@]}")                 # Duplicate
            # Fruits=("${Fruits[@]}" "${Veggies[@]}") # Concatenate
            # lines=(`cat "logfile"`)                 # Read from file
            # echo ${Fruits[0]}           # Element #0
            # echo ${Fruits[-1]}          # Last element
            # echo ${Fruits[@]}           # All elements, space-separated
            # echo ${#Fruits[@]}          # Number of elements
            # echo ${#Fruits}             # String length of the 1st element
            # echo ${#Fruits[3]}          # String length of the Nth element
            # echo ${Fruits[@]:3:2}       # Range (from position 3, length 2)
            # echo ${!Fruits[@]}          # Keys of all elements, space-separated
        # bash $""





        
    
    
    
    grammar[:variable] = Pattern.new(
        match: variable,
        tag_as: "variable.other",
    )
    
    grammar[:line_continuation_character] = Pattern.new(
        match: /\\\n/,
        tag_as: "constant.character.escape.line-continuation",
    )
    
    grammar[:attribute] = PatternRange.new(
        start_pattern: Pattern.new(
                match: /\[\[/,
                tag_as: "punctuation.section.attribute.begin"
            ),
        end_pattern: Pattern.new(
                match: /\]\]/,
                tag_as: "punctuation.section.attribute.end",
            ),
        tag_as: "support.other.attribute",
        # tag_content_as: "support.other.attribute", # <- alternative that doesnt double-tag the start/end
        includes: [
            :attributes_context,
        ]
    )

# 
# imports
# 
    grammar.import(PathFor[:pattern]["comments"])
    grammar.import(PathFor[:pattern]["string"])
    grammar.import(PathFor[:pattern]["numeric_literal"])

#
# Save
#
name = "shell"
grammar.save_to(
    syntax_name: name,
    syntax_dir: "./autogenerated",
    tag_dir: "./autogenerated",
)