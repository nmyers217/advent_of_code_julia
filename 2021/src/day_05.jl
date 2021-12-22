function isstraightline((p1, p2))
    (x1, y1) = p1
    (x2, y2) = p2
    x1 == x2 || y1 == y2
end

normalize(n) = n > 0 ? 1 : n < 0 ? -1 : 0

function points((p1, p2))
    loc, dir = p1, normalize.(p2 .- p1)
    result = []
    while loc != p2
        push!(result, loc)
        loc = loc .+ dir
    end
    push!(result, loc)
    result
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    lines = map(eachmatch(r"(\d+),(\d+) -> (\d+),(\d+)", input)) do m
        (x1, y1, x2, y2) = parse.(Int, m.captures)
        [(x1, y1), (x2, y2)]
    end

    solve(lines) = begin
        seen = Dict()
        for line in lines
            for point in points(line)
                cnt = get!(seen, point, 0)
                seen[point] = cnt + 1
            end
        end
        length([k for (k, v) in seen if v >= 2])
    end

    solve(filter(isstraightline, lines)), solve(lines)
end

@time @show solve()