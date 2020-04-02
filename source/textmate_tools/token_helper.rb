require 'json'
require 'yaml'
require 'set'
require 'deep_clone' # gem install deep_clone
require 'pathname'

class NegatedSymbol
    def initialize(a_symbol)
        @symbol = a_symbol
    end
    def to_s
        return "not(#{@symbol.to_s})"
    end
    def to_sym
        return @symbol
    end
end

class Symbol
    def !@
        return NegatedSymbol.new(self)
    end
end

class TokenHelper
    attr_accessor :tokens
    def initialize(tokens, for_each_token:nil)
        @tokens = tokens
        if for_each_token != nil
            for each in @tokens
                for_each_token[each]
            end
        end
    end


    def tokensThat(*adjectives)
        matches = @tokens.select do |each_token|
            output = true
            for each_adjective in adjectives
                # make sure to fail on negated symbols
                if each_adjective.is_a? NegatedSymbol
                    if each_token[each_adjective.to_sym] == true
                        output = false
                        break
                    end
                elsif each_token[each_adjective] != true
                    output = false
                    break
                end
            end
            output
        end
        return matches
    end

    def representationsThat(*adjectives)
        matches = self.tokensThat(*adjectives)
        return matches.map do |each| each[:representation] end
    end

    def lookBehindToAvoidWordsThat(*adjectives)
        array_of_invalid_names = self.representationsThat(*adjectives)
        return /\b/.lookBehindToAvoid(/#{array_of_invalid_names.map { |each| '\W'+each+'|^'+each } .join('|')}/)
    end

    def lookAheadToAvoidWordsThat(*adjectives)
        array_of_invalid_names = self.representationsThat(*adjectives)
        return /\b/.lookAheadToAvoid(/#{array_of_invalid_names.map { |each| each+'\W|'+each+'\$' } .join('|')}/)
    end

    def that(*adjectives)
        matches = tokensThat(*adjectives)
        return /(?:#{matches.map {|each| Regexp.escape(each[:representation]) }.join("|")})/
    end
end

class Array
    def without(*args)
        copy = self.clone
        for each in args
            copy.delete(each)
        end
        return copy
    end
end
