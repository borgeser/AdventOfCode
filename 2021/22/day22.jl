parseInt(x) = parse(Int, x)

function parse_dimension(str)
	axis = str[1]
	start, stop = split(str[3:end], "..")
	return (axis, (parseInt(start), parseInt(stop)))
end

function parse_coords(str)
	elems = split(str, ",")
	tuples = map(parse_dimension, elems)
	return Dict(tuples)
end

raw_lines = readlines("input_cropped.txt") .|> x -> split(x, " ")
lines = [(row[1], parse_coords(row[2])) for row in raw_lines]

function get_cells(coords)
	res = Set()
	for i in coords['x'][1]:coords['x'][2]
		for j in coords['y'][1]:coords['y'][2]
			for k in coords['z'][1]:coords['z'][2]
				push!(res, (i, j, k))
			end
		end
	end
	return res
end

function part1(lines)
	on_cells = Set{Tuple{Int, Int, Int}}()
	for line in lines
		cells = get_cells(line[2])
		if line[1] == "on"
			on_cells = union(on_cells, cells)
		else
			on_cells = setdiff(on_cells, cells)
		end
	end
	return length(on_cells)
end

part1(lines) |> println
