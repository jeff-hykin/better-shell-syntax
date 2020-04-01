require 'json'
require 'yaml'
require 'set'
require 'deep_clone' # gem install deep_clone
require 'pathname'

#
# Recursive value setting
#
# TODO: these names/methods should probably be formalized and then put inside their own ruby gem
# TODO: methods should probably be added for other containers, like sets
# TODO: probably should use blocks instead of a lambda
#     # the hash (or array) you want to change
#     a_hash = {
#         a: nil,
#         b: {
#             c: nil,
#             d: {
#                 e: nil
#             }
#         }
#     }
#     # lets say you want to convert all the nil's into empty arrays []
#     # then you'd do:
#     a_hash.recursively_set_each_value! ->(each_value, each_key) do
#         if each_value == nil
#             # return an empty list
#             []
#         else
#             # return the original
#             each_value
#         end
#     end
#     # this would result in:
#     a_hash = {
#         a: [],
#         b: {
#             c: []
#             d: {
#                 e: []
#             }
#         }
#     }
class Hash
    def recursively_set_each_value!(a_lambda)
        for each_key, each_value in self.clone
            # if this was a tree, then start by exploring the tip of the first root
            # (rather than the base of the tree)
            # if it has a :recursively_set_each_value! method, then call it
            if self[each_key].respond_to?(:recursively_set_each_value!)
                self[each_key].recursively_set_each_value!(a_lambda)
            end
            # then allow manipulation of the value
            self[each_key] = a_lambda[each_value, each_key]
        end
    end
end

class Array
    def recursively_set_each_value!(a_lambda)
        new_values = []
        clone = self.clone
        clone.each_with_index do |each_value, each_key|
            # if it has a :recursively_set_each_value! method, then call it
            if self[each_key].respond_to?(:recursively_set_each_value!)
                self[each_key].recursively_set_each_value!(a_lambda)
            end
            self[each_key] = a_lambda[each_value, each_key]
        end
    end
end
