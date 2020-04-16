def isNonEmptyRegexp(arg) arg.is_a?(Regexp) && arg != //  end
def isEmptyRegexp(arg)    !arg.is_a?(Regexp) || arg == // end

def isNonEmptyHash(arg)   arg.is_a?(Hash) && arg.length.positive?   end
def isNonEmptyString(arg) arg.is_a?(String) && arg.length.positive? end
