# **Monkey Patch**<br>
# Implements operator `!` which returns a `Symbol`
# prefixed with an '!'.<br>
# Implements instance method `negated?`.<br><br>
class Symbol
	def negated?() self[0] == '!' end

	def !@
		(negated? ? self[1..-1] : '!' + to_s).to_sym
	end
end

# Helpers for Tokens
class TokenHelper
	# @return [Array<Hash>]
	attr_accessor :tokens

	# @param tokens [Array<Hash>]
	# @param for_each_token [Proc]
	def initialize(tokens, for_each_token: nil)
		@tokens = tokens

		@tokens.each { |token| for_each_token.call(token) } unless for_each_token.nil?
	end

	# Returns an array of tokens
	# @param adjectives [Array<Symbol>]
	def tokensThat(*adjectives)
		matches = @tokens.select do |token|
			output = true

			adjectives.each do |adjective|
				# Don't output the token if there is a negated adjective that is valid for the token
				# or a non-negated one that is not valid.
				if adjective.negated? && token[adjective] == true || !adjective.negated? && token[adjective] != true
					output = false
					break
				end
			end

			output
		end

		matches
	end

	def representationsThat(*adjectives)
		tokensThat(*adjectives).map { |match| match[:representation] }
	end

	def lookBehindToAvoidWordsThat(*adjectives)
		array_of_invalid_names = representationsThat(*adjectives)

		/\b/.lookBehindToAvoid(/#{array_of_invalid_names.map { |invalidName| '\W' + invalidName + '|^' + invalidName } .join('|')}/)
	end

	def lookAheadToAvoidWordsThat(*adjectives)
		array_of_invalid_names = representationsThat(*adjectives)

		/\b/.lookAheadToAvoid(/#{array_of_invalid_names.map { |invalidName| invalidName + '\W|' + invalidName + '\$' } .join('|')}/)
	end

	def that(*adjectives)
		/(?:#{tokensThat(*adjectives).map { |match| Regexp.escape(match[:representation]) } .join('|')})/
	end
end

# **Monkey Patch**<br>
# Implements instance method `without`.<br><br>
class Array
	# Returns a shallow copy of `self` from which each provided element
	# has been removed.<br>
	# Elements that don't exist are silently ignored.
	# @param elements [Array] List of elements to be removed
	def without(*elements)
		copy = clone

		elements.each { |e| copy.delete(e) }

		copy
	end
end
