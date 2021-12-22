function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    strs = split(strip(input), "\n")

    matchcount(rx, str) = eachmatch(rx, str) |> collect |> length

    isnice(str) = begin
        vowels = matchcount(r"[aeiou]", str)
        pairs = matchcount(r"(.)\1", str)
        badstrs = matchcount(r"ab|cd|pq|xy", str)
        vowels >= 3 && pairs >= 1 && badstrs == 0
    end

    isnicer(str) = begin
        matchcount(r"(..).*\1", str) == 1 && matchcount(r"(.).\1", str) >= 1
    end

    count(isnice, strs), count(isnicer, strs)
end

@time @show solve()
