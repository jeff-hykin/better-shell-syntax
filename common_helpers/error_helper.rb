require_relative('./multiline_string.rb')

# Raises an exception with a message and prints the location where the error occurred.<br><br>
# This method takes a list of strings (and other objects) to compose the message
# and inserts newlines between the provided strings.
# @param args [Array] List of strings to be concatenated.\
#     \
#     You may also provide any object, it will be converted to a string
#     by calling its `inspect` method if it's a `RegExp`, else by calling its `to_s` method.\
#     An argument of `nil` will begin a new paragraph.
def error(*args)
	# One preceding newline to get out of the 'Exception:' line,
	# another one to get an empty line before the message.
	# Append a newline to the message to get an empty line
	# between the last line of the message and the error location.
	raise(Exception.new(), String.multiline({ autoNewline: true, precedingNewlines: 2 }, *args) + "\n", caller)
end

# Prints a warning message.<br><br>
# This method takes a list of strings (and other objects) to compose the message
# and inserts newlines between the provided strings.
# @param args [Array] List of strings to be concatenated.\
#     \
#     You may also provide any object, it will be converted to a string
#     by calling its `inspect` method if it's a `RegExp`, else by calling its `to_s` method.\
#     An argument of `nil` will begin a new paragraph.
def warning(*args)
	# Two preceding newlines to get two empty lines after previous output, if any.
	puts(String.multiline({ autoNewline: true, precedingNewlines: 2 }, 'Warning:', nil, *args))
end
