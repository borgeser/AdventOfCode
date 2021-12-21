pos_x(n, v) = n < v ? (2*v-n)*(n+1)/2 : v*(v+1)/2

pos_y(n, v) = (2*v-n)*(n+1)/2

function find_valid_x_velocity(min_x, max_x) # min_x and max_x are positive
	res = Int[]
	for x in 1:max_x
		p = 0
		n = 0
		while (p < max_x) && (n <= x)
			p = pos_x(n, x)
			if min_x <= p <= max_x
				push!(res, x)
				break
			end
			n += 1
		end
	end
	return res
end

function find_valid_y_velocity(min_y, max_y) min_y and max_y are negative
	res = Int[]
	for y in min_y:-min_y
		p = 0
		n = 0
		while (p > min_y)
			p = pos_y(n, y)
			if min_y <= p <= max_y
				push!(res, y)
				break
			end
			n += 1
		end
	end
	return res
end

function best_y(min_x, max_x, min_y, max_y)
	possible_x = find_valid_x_velocity(min_x, max_x)
	possible_y = find_valid_y_velocity(min_y, max_y)
	for y in reverse(possible_y)
		for x in possible_x
			py = 0
			n = 0
			while (py > min_y)
				px = pos_x(n, x)
				py = pos_y(n, y)
				if (min_x <= px <= max_x) && (min_y <= py <= max_y)
					return y
				end
				n += 1
			end
		end
	end
end

function part1(min_x, max_x, min_y, max_y)
	y = best_y(min_x, max_x, min_y, max_y)
	return maximum([pos_y(y-1, y), pos_y(y, y)])
end

part1(20, 30, -10, -5) |> println
part1(206, 250, -105, -57) |> println


function part2(min_x, max_x, min_y, max_y)
	possible_x = find_valid_x_velocity(min_x, max_x)
	possible_y = find_valid_y_velocity(min_y, max_y)
	res = Tuple{Int, Int}[]
	for y in possible_y
		for x in possible_x
			py = 0
			n = 0
			while (py > min_y)
				px = pos_x(n, x)
				py = pos_y(n, y)
				if (min_x <= px <= max_x) && (min_y <= py <= max_y)
					push!(res, (x, y))
					break
				end
				n += 1
			end
		end
	end
	return length(res)
end


part2(20, 30, -10, -5) |> println
part2(206, 250, -105, -57) |> println
