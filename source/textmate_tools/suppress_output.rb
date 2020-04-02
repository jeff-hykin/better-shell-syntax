require 'json'
require 'yaml'
require 'set'
require 'deep_clone' # gem install deep_clone
require 'pathname'

# taken from https://gist.github.com/moertel/11091573
# Temporarily redirects STDOUT and STDERR to /dev/null
# but does print exceptions should there occur any.
# Call as:
#   suppress_output { puts 'never printed' }
#
def suppress_output
    begin
        original_stderr = $stderr.clone
        original_stdout = $stdout.clone
        $stderr.reopen(File.new('/dev/null', 'w'))
        $stdout.reopen(File.new('/dev/null', 'w'))
        retval = yield
    rescue Exception => e
        $stdout.reopen(original_stdout)
        $stderr.reopen(original_stderr)
        raise e
    ensure
        $stdout.reopen(original_stdout)
        $stderr.reopen(original_stderr)
    end
    retval
end
