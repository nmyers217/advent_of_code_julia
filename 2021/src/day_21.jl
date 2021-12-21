function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    players = map(eachmatch(r"\w+ \d \w+ \w+: (\d)", input)) do m
        parse(Int, m.captures |> first)
    end

    partone() = begin
        die, die_i, rolls = collect(1:100), 1, 0
        nums = collect(1:10)
        positions = [p for p in players]
        scores = [0 for _ in players]

        while true
            for i in eachindex(positions)
                roll = 0
                for _ in 1:3
                    roll += die[mod1(die_i, length(die))]
                    die_i += 1
                    rolls += 1
                end
                positions[i] += roll
                scores[i] += nums[mod1(positions[i], length(nums))]
                if scores[i] >= 1000
                    return scores[mod1(i + 1, length(scores))] * rolls
                end
            end
        end
    end

    parttwo() = begin
        memo = Dict()

        play(turn, p1, p2, s1, s2) = begin
            if s1 >= 21 return 1 end
            if s2 >= 21 return 0 end
            if haskey(memo, (turn, p1, p2, s1, s2))
                return memo[(turn, p1, p2, s1, s2)]
            end

            result = 0
            for roll1 in 1:3, roll2 in 1:3, roll3 in 1:3
                roll = roll1 + roll2 + roll3
                result += if turn == 0
                    pos = mod1(p1 + roll, 10)
                    play(1, pos, p2, s1 + pos, s2) 
                else
                    pos = mod1(p2 + roll, 10)
                    play(0, p1, pos, s1, s2 + pos) 
                end
            end

            memo[(turn, p1, p2, s1, s2)] = result
            return result
        end

        play(0, players[1], players[2], 0, 0)
    end

    partone(), parttwo()
end

@time solve()