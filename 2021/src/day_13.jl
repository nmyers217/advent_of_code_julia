function parseinput(input)
    (left, right) = split(strip(input), "\n\n")
    points = map(eachmatch(r"(\d+),(\d+)", left)) do m
        tuple(parse.(Int, m.captures)...)
    end
    folds = map(eachmatch(r"fold along (\w)=(\d+)", right)) do m
        (axis, str) = m.captures
        (axis, parse(Int, str))
    end
    points, folds
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    (points, folds) = parseinput(input)

    partone = nothing
    for (i, (axis, n)) in enumerate(folds)
        points = if axis == "x"
            Set((x < n ? x : n + n - x, y) for (x, y) in points)
        else
            Set((x, y < n ? y : n + n - y) for (x, y) in points)
        end

        if i == 1; partone= length(points) end
    end
    
    println(partone)

    rows = maximum([y for (_, y) in points])
    cols = maximum([x for (x, _) in points])
    for y in 0:rows
        for x in 0:cols
            print((x, y) in points ? '#' : ' ')
        end
        print("\n")
    end
end

@time solve()