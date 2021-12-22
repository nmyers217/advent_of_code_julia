using Pkg
Pkg.add("DataStructures")
using DataStructures

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    polymer = split(strip(input), "\n\n") |> first
    rules = reduce(eachmatch(r"(\w+) -> (\w)", input), init=Dict()) do acc, m
        (k, v) = m.captures
        acc[k] = v
        acc
    end
    paircounts = join.(zip(polymer, polymer[2:end])) |> counter

    iterate!() = begin
        next = counter(String)
        for (pair, count) in paircounts
            insert = rules[pair]
            (a, b) = "$(pair[1])$(insert)", "$(insert)$(pair[2])"
            next[a] = get(next, a, 0) + count
            next[b] = get(next, b, 0) + count
        end
        paircounts = next
    end

    countletters() = begin
        lettercounts = counter(Char)
        for (pair, count) in paircounts
            lettercounts[pair[1]] = get(lettercounts, pair[1], 0) + count
        end
        # NOTE: need to add 1 for the last letter in the polymer
        lettercounts[polymer[end]] = get(lettercounts, polymer[end], 0) + 1

        (min, max) = extrema(values(lettercounts))
        max - min
    end

    partone = begin
        for _ in 1:10 iterate!() end
        countletters()
    end

    parttwo = begin
        for _ in 11:40 iterate!() end
        countletters()
    end

    partone, parttwo
end

@time @show solve()