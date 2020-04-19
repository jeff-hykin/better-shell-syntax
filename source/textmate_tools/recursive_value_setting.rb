# TODO: these names/methods should probably be formalized and then put inside their own ruby gem.
# TODO: methods should probably be added for other containers, like sets.

# **Monkey Patch**<br>
# Implements instance method `recursively_set_each_value!`.<br><br>
class Hash
	# Recursive value setting
	#
	# Example:
	#
	#     a_hash = {
	#         a: nil,
	#         b: {
	#             c: nil,
	#             d: {
	#                 e: nil
	#             }
	#         }
	#     }
	#
	# Let's say you want to convert all the `nil`s into empty arrays (`[]`), then you'd do:
	#
	#     a_hash.recursively_set_each_value! { |value, key| value.nil? ? [] : value }
	#
	# This would result in:
	#
	#     a_hash = {
	#         a: [],
	#         b: {
	#             c: []
	#             d: {
	#                 e: []
	#             }
	#         }
	#     }
	# @param block Will be called for each element, passing the `value` and respective `key` to it.\
	#     The return value of `block` will be the the new value for `key`.\
	#     Prior to calling `block`, if a `value` is a `Hash` or an `Array`, this method will be called
	#     on that object with `block`.
	# @yieldparam value
	# @yieldparam key
	# @yieldreturn The new value to be set for `key`.
	# @return [void]
	def recursively_set_each_value!(&block)
		for key, value in clone
			# if this was a tree, then start by exploring the tip of the first root
			# (rather than the base of the tree)
			# if it has a :recursively_set_each_value! method, then call it
			self[key].recursively_set_each_value!(&block) if self[key].respond_to?(:recursively_set_each_value!)

			# then allow manipulation of the value
			self[key] = block.call(value, key)
		end
	end
end

# **Monkey Patch**<br>
# Implements instance method `recursively_set_each_value!`.<br><br>
class Array
	# Recursive value setting
	#
	# Example:
	#
	#     an_array = [
	#         nil,
	#         [
	#             nil,
	#             [nil]
	#         ]
	#     ]
	#
	# Let's say you want to convert all the `nil`s into empty strings, then you'd do:
	#
	#     an_array.recursively_set_each_value! { |value, index| value.nil? ? '' : value }
	#
	# This would result in:
	#
	#     an_array = [
	#         "",
	#         [
	#             "",
	#             [""]
	#         ]
	#     ]
	# @param block Will be called for each element, passing the `value` and respective `index` to it.\
	#     The return value of `block` will be the the new value for `key`.\
	#     Prior to calling `block`, if a `value` is a `Hash` or an `Array`, this method will be called
	#     on that object with `block`.
	# @yieldparam value
	# @yieldparam index
	# @yieldreturn The new value to be set for `key`.
	# @return [void]
	def recursively_set_each_value!(&block)
		clone.each_with_index do |value, index|
			# if it has a :recursively_set_each_value! method, then call it
			self[index].recursively_set_each_value!(&block) if self[index].respond_to?(:recursively_set_each_value!)

			self[index] = block.call(value, index)
		end
	end
end
