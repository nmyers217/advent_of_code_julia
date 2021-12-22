function getgrid(input)
    lines = split(strip(input), "\n")
    rows, cols = lines |> length, lines |> first |> length
    result = fill(0, (rows, cols))
    for (y, line) in enumerate(lines)
        for (x, v) in enumerate(line)
            result[y, x] = parse(Int, v)
        end
    end
    result
end

function dijkstra(grid)
    dirs = [(0, -1), (1, 0), (0, 1), (-1, 0)]
    rows, cols = size(grid, 1), size(grid, 2)

    queue = [(0, (1, 1))]
    seen = Set([(1, 1)])
    while !isempty(queue)
        (score, (x, y)) = popfirst!(queue)

        if (x, y) == (cols, rows) return score end

        for d in dirs
            (nx, ny) = (x, y) .+ d
            if ny < 1 || ny > rows || nx < 1 || nx > cols continue end
            if (nx, ny) in seen continue end
            push!(queue, (score + grid[ny, nx], (nx, ny)))
            push!(seen, (nx, ny))
        end

        sort!(queue, by=first)
    end
end

function expand(grid)
    inc(a, b) = mod1((a + b), 9)
        
    result = nothing
    for y in 0:4
        tile = map(el -> inc(el, y), grid)
        row = nothing
        for x in 0:4
            nexttile = map(el -> inc(el, x), tile)
            row = isnothing(row) ? tile : hcat(row, nexttile)
        end
        result = isnothing(result) ? row : vcat(result, row)
    end
    result
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    grid = getgrid(input)
    grid |> dijkstra, grid |> expand |> dijkstra
end

@time @show solve()