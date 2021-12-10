pairs = Dict('(' => ')', '[' => ']', '{' => '}', '<' => '>')

function islinecorrupted(line)
    stack = []

    for c in line
        if c in keys(pairs)
            push!(stack, c)
        end
        if c in values(pairs)
            if pairs[pop!(stack)] != c
                return true, c, stack
            end
        end
    end

    return false, nothing, stack
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    lines = strip.(split(strip(input), "\n"))

    partone = begin
        scores = Dict(')' => 3, ']' => 57, '}' => 1197, '>' => 25137)
        result = 0
        for line in lines
            iscorrupted, c = islinecorrupted(line)
            if iscorrupted result += scores[c] end
        end
        result
    end

    parttwo = begin
        scores = Dict(')' => 1, ']' => 2, '}' => 3, '>' => 4)
        result = []
        for line in lines
            iscorrupted, _, stack = islinecorrupted(line)
            if iscorrupted continue end
            score = 0
            while !isempty(stack)
                score *= 5
                score += scores[pairs[pop!(stack)]]
            end
            push!(result, score)
        end
        sort(result)[convert(Int, ceil(length(result) / 2))]
    end

    partone, parttwo
end

@time solve()