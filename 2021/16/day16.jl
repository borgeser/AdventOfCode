#Composite = Union{Int,Container}

struct Packet
	version::Int
	type::Int
	payload#::Composite
end

struct Container
	f
	children::Vector{Packet}
end

hex_to_bin_dict = Dict(
'0' => "0000",
'1' => "0001",
'2' => "0010",
'3' => "0011",
'4' => "0100",
'5' => "0101",
'6' => "0110",
'7' => "0111",
'8' => "1000",
'9' => "1001",
'A' => "1010",
'B' => "1011",
'C' => "1100",
'D' => "1101",
'E' => "1110",
'F' => "1111"
)

parse_bin(x) = parse(Int, x, base=2)

parse_hexa(str) = map(x -> hex_to_bin_dict[x], collect(str)) |> (y -> reduce(*, y))

function extract_group(str)
	is_end = str[1] == '0'
	return is_end, str[2:5], str[6:end]
end

function extract_value(str)
	res = ""
	next = str
	is_end = false
	while !is_end
		is_end, current, next = extract_group(next)
		res *= current
	end
	return parse_bin(res), next
end

function get_operator(type_id)
	if type_id == 0
		return sum
	elseif type_id == 1
		return prod
	elseif type_id == 2
		return minimum
	elseif type_id == 3
		return maximum
	elseif type_id == 5
		return arr -> arr[1] > arr[2] ? 1 : 0
	elseif type_id == 6
		return arr -> arr[1] < arr[2] ? 1 : 0
	else
		return arr -> arr[1] == arr[2] ? 1 : 0
	end
end

function parse_packet(str)
	version = parse_bin(str[1:3])
	type_id = parse_bin(str[4:6])
	if type_id == 4
		value, next = extract_value(str[7:end])
		return Packet(version, type_id, value), next
	else
		f = get_operator(type_id)
		if str[7] == '0'
			sub_length = parse_bin(str[8:22])
			data = str[23:23+sub_length-1]
			next = str[23+sub_length:end]
			children = get_children(data)
			return Packet(version, type_id, Container(f, children)), next
		else
			sub_count = parse_bin(str[8:18])
			data = str[19:end]
			children, next = get_children(sub_count, data)
			return Packet(version, type_id, Container(f, children)), next
		end
	end
end

parse_root_packet(x) = parse_packet(x)[1]

function get_children(str)
	children = Packet[]
	next = str
	while length(next) > 7
		child, next = parse_packet(next)
		push!(children, child)
	end
	return children
end

function get_children(count, str)
	children = Packet[]
	next = str
	for _ in 1:count
		child, next = parse_packet(next)
		push!(children, child)
	end
	return children, next
end

function version_sum(packet)
	if isa(packet.payload, Int)
		return packet.version
	else
		return packet.version + sum(version_sum.(packet.payload.children))
	end
end

part1(str) = (parse_root_packet ∘ parse_hexa)(str) |> version_sum

input = readline("input.txt")

println(part1(input))

### Part 2 ###

function value_after_operations(packet)
	if isa(packet.payload, Int)
		return packet.payload
	else
		container = packet.payload
		f = container.f
		return f(value_after_operations.(container.children))
	end
end

part2(str) = (parse_root_packet ∘ parse_hexa)(str) |> value_after_operations

part2(input) |> println
