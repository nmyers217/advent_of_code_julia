function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    chars = split(strip(input), "")

    partone = reduce((acc, c) -> acc += c == "(" ? 1 : -1 , chars, init=0)

    parttwo = begin
        result, floor = 0, 0
        for (i, c) in enumerate(chars)
            floor += c == "(" ? 1 : -1
            if floor == -1
                result = i
                break
            end
        end
        result
    end

    partone, parttwo
end

@time solve()
