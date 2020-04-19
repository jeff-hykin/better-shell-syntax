def isNonEmptyRegexp(arg) arg.is_a?(Regexp) && arg != //   end
def isNonEmptyHash(arg)   arg.is_a?(Hash) && !arg.empty?   end
def isNonEmptyString(arg) arg.is_a?(String) && !arg.empty? end
