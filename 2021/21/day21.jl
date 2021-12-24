function get_die_value(index, max)
	value = (index-1) + (index)%max + (index+1)%max + 3
	next_index = (index+2)%max + 1
	return value, next_index
end

function advance(coord, value, max)
	return (coord + value - 1) % max + 1
end

function play(player1_start, player2_start)
	players_pos = [player1_start, player2_start]
	players_scores = [0, 0]
	die_index = 1
	turn = 0
	while (players_scores[1] < 1000) && (players_scores[2] < 1000)
		turn += 1
		player_idx = (turn-1) % 2 + 1
		die_value, die_index = get_die_value(die_index, 100)
		players_pos[player_idx] = advance(players_pos[player_idx], die_value, 10)
		players_scores[player_idx] += players_pos[player_idx]
	end
	return players_scores, turn
end

function part1(player1_start, player2_start)
	players_scores, turn = play(player1_start, player2_start)
	return minimum(players_scores) * turn * 3
end

part1(10,9) |> println

function get_new_states(start_1, start_2, score_1, score_2)
	res = []
	for die_1 in all_dices
		pos_1 = advance(start_1, die_1, 10)
		new_score_1 = score_1 + pos_1
		if new_score_1 >= 21 # game over for player 2
			push!(res, (pos_1, start_2, new_score_1, score_2))
		else
			for die_2 in all_dices
				pos_2 = advance(start_2, die_2, 10)
				push!(res, (pos_1, pos_2, new_score_1, score_2 + pos_2))
			end
		end
	end
	return res
end

all_dices = [i+j+k for i in 1:3 for j in 1:3 for k in 1:3]

function winning_count(start_1, start_2, score_1, score_2)
	if score_1 >= 21
		return 1
	elseif score_2 >= 21
		return 0
	end
	states = get_new_states(start_1, start_2, score_1, score_2)
	return sum([memoized_winning_count(state...) for state in states])
end

cache = Dict()

function memoized_winning_count(start_1, start_2, score_1, score_2)
	key = (start_1, start_2, score_1, score_2)
	if haskey(cache, key)
		return cache[key]
	else
		value = winning_count(start_1, start_2, score_1, score_2)
		cache[key] = value
		return value
	end
end

memoized_winning_count(10,9,0,0) |> println