mutable struct Node
    left::Union{Int, Node}
    right::Union{Int, Node}
end

function parse_node(str)::Union{Int, Node}
	if str[1] != '[' # value
		return parse(Int, str)
	else # node
		inside_str = str[2:end-1] # remove brackets
		count = 0
		for i in 1:length(inside_str)
			if inside_str[i] == '['
				count += 1
			elseif inside_str[i] == ']'
				count -= 1
			end
			if count == 0
				return Node(parse_node(inside_str[1:i]), parse_node(inside_str[i+2:end])) 
			end
		end
	end
end

function get(node, indexes)
	if length(indexes) == 0
		return node
	elseif indexes[1] == 1
		return get(node.left, indexes[2:end])
	else
		return get(node.right, indexes[2:end])
	end
end

function set!(node, indexes, value)
	if length(indexes) == 1
		if indexes[1] == 1
			node.left = value
		else
			node.right = value
		end
	elseif indexes[1] == 1
		set!(node.left, indexes[2:end], value)
	else
		set!(node.right, indexes[2:end], value)
	end
end

function child_indexes(indexes, identifier)
	return vcat(indexes, [identifier])
end

function parent_indexes(indexes)
	return indexes[1:end-1]
end

function neighbour_indexes(node, indexes)
	my_idx = last(indexes)
	other_idx = my_idx == 1 ? 2 : 1
	return child_indexes(parent_indexes(indexes), other_idx)
end

function get_extreme_leaf_index(node, indexes, identifier)
	current_idx = indexes
	while !isa(get(node, current_idx), Int)
		current_idx = child_indexes(current_idx, identifier)
	end
	return current_idx
end

function get_side_indexes(node, indexes, identifier, other_identifier)
	if last(indexes) == other_identifier # neighbours
		neighbour_idx = neighbour_indexes(node, indexes)
		leaf_idx = get_extreme_leaf_index(node, neighbour_idx, other_identifier)
		return leaf_idx
	end
	current_idx = parent_indexes(indexes)
	while length(current_idx) > 0 && last(current_idx) == identifier
		current_idx = parent_indexes(current_idx)
	end
	if length(current_idx) == 0
		return nothing
	end
	neighbour_idx = neighbour_indexes(node, current_idx)
	leaf_idx = get_extreme_leaf_index(node, neighbour_idx, other_identifier)
	return leaf_idx
end

get_left_neighbour_indexes(node, indexes) = get_side_indexes(node, indexes, 1, 2)
get_right_neighbour_indexes(node, indexes) = get_side_indexes(node, indexes, 2, 1)

function sum!(node, from_indexes, to_indexes)
	if isnothing(to_indexes)
		return
	end
	new_value = get(node, from_indexes) + get(node, to_indexes)
	set!(node, to_indexes, new_value)
end

sum_left_child!(node, indexes) = sum!(node, child_indexes(indexes, 1), get_left_neighbour_indexes(node, child_indexes(indexes, 1)))
sum_right_child!(node, indexes) = sum!(node, child_indexes(indexes, 2), get_right_neighbour_indexes(node, child_indexes(indexes, 2)))

function explode!(node, indexes)
	sum_left_child!(node, indexes)
	sum_right_child!(node, indexes)
	set!(node, indexes, 0)
end

function split!(node, indexes)
	half_value = get(node, indexes) / 2
	new_node = Node(floor(Int, half_value), ceil(Int, half_value))
	set!(node, indexes, new_node)
end

function leftest_index(node)
	result_idx = []
	while isa(get(node, result_idx), Node)
		result_idx = child_indexes(result_idx, 1)
	end
	return result_idx
end

function reduce_node!(node)
	current_idx = leftest_index(node)
	to_split = []
	while !isnothing(current_idx)
		if length(current_idx) == 5 # immediate explosion
			explode!(node, parent_indexes(current_idx))
			current_idx = leftest_index(node)
		elseif get(node, current_idx) >= 10 # delayed split
			push!(to_split, current_idx)
			current_idx = get_right_neighbour_indexes(node, current_idx)
		else
			current_idx = get_right_neighbour_indexes(node, current_idx)
		end
	end
	if length(to_split) > 0
		split!(node, first(to_split))
		reduce_node!(node)
	end
end

function add(left, right)
	node = Node(left, right)
	reduce_node!(node)
	return node
end

function add_all(lines)
	res = first(lines)
	for line in lines[2:end]
		res = add(res, line)
	end
	return res
end

function magnitude(node)
	if isa(node, Int)
		return node
	else
		return 3 * magnitude(node.left) + 2 * magnitude(node.right)
	end
end

lines = readlines("input.txt") .|> parse_node
add_all(lines) |> magnitude |> println
