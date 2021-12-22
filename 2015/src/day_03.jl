function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    moves = split(strip(input), "")
    dirs = Dict(">" => (1, 0), "v" => (0, 1), "<" => (-1, 0), "^" => (0, -1))

    partone = begin
        cur, seen = (0,0), Dict((0, 0) => 1)
        for move in moves
            cur = cur .+ dirs[move]
            seen[cur] = get!(seen, cur, 0) + 1
        end
        count(>=(1), values(seen))
    end

    parttwo = begin
        i, cur, seen = 1, [(0, 0), (0, 0)], Dict((0, 0) => 2)
        for move in moves
            cur[i] = cur[i] .+ dirs[move]
            seen[cur[i]] = get!(seen, cur[i], 0) + 1
            i = mod1(i + 1, length(cur))
        end
        count(>=(1), values(seen))
    end

    partone, parttwo
end

@time @show solve()
