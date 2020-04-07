# **Monkey Patch**<br>
# Literal multiline strings look really awkward since each line
# after the first one must not be indented.<br>
# Too bad thay Ruby doesn't concatenate string literals in consecutive lines
# automatically as C++ does and concatenation operators before/after line breaks
# work only with line continuation, i. e. placing a backslash at EOL.<br>
# This monkey patch implements the class methods `multiline`
# and `setMultilinePrecedingNewlines`.<br><br>
class String
	@@multilineDefaultOpts = { autoNewline: false, precedingNewlines: 1 }
	@@validOptKeys         = @@multilineDefaultOpts.keys

	# Sets the default value for `String.multiline` method's `:precedingNewlines` option.
	# @param value [Integer]
	# @return [void]
	def self.setMultilinePrecedingNewlines(value)
		raise(Exception.new(), String.multiline({ precedingNewlines: 2 }, 'Please provide a non-negative value.'), caller) if value.negative?

		@@multilineDefaultOpts[:precedingNewlines] = value
	end

	# This method takes a list of strings (and other objects) and returns a string that
	# is the concatenation of the provided strings.<br>
	# Furthermore, it optionally inserts newlines between the provided strings and/or prepends
	# an arbitrary number of newlines to the resulting string.
	# @param args [Array] List of strings to be concatenated.\
	#     \
	#     You may also provide any object, it will be converted to a string
	#     by calling its `inspect` method if it's a `RegExp`, else by calling its `to_s` method.\
	#     An argument of `nil` will cause a line break.\
	#     \
	#     You may provide a `Hash` as first argument to set options as follows:
	#         - `:autoNewline` Whether to insert newlines between the provided strings and to use `nil` to begin a new paragraph. Defaults to `false`.
	#         - `:precedingNewlines` How many newlines to prepend to the resulting string. Defaults to 1 or the value set via `String.multilinePrecedingNewlines`, if any.
	#
	#       You may provide `:autoNewline` as a shortcut for `{ autoNewline: true }`.
	# @return [String] The multiline string.
	def self.multiline(*args)
		opts =
			case args[0]
				when Hash
					invalidOptKeys = args[0].keys - @@validOptKeys
					raise(Exception.new(), String.multiline({ precedingNewlines: 2 }, 'Invalid option(s): ', invalidOptKeys.join(', ')), caller) if invalidOptKeys.length.positive?

					# We could use Hash#merge here, but I like the perfect analogy to JS ;)
					{ **@@multilineDefaultOpts, **args.shift }
				when :autoNewline
					# Using the "hash rocket", we can use any expression as key like in Perl.
					{ **@@multilineDefaultOpts, args.shift => true }
				else
					@@multilineDefaultOpts
			end

		# Turn nil into "\n" if !opts[:autoNewline], else turn nil into ''.
		# Turn non-string objects into strings.
		args.map! do |arg|
			case arg
				when nil    then !opts[:autoNewline] ? "\n" : '' # We can check for a certain value...
				when String then arg                             # ... as well as for a type. Nice feature!
				when Regexp then arg.inspect
				else arg.to_s
			end
		end

		args.join(opts[:autoNewline] ? "\n" : '').prepend("\n" * opts[:precedingNewlines])
	end
end
