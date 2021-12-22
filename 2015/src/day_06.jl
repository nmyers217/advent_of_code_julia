function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    mapgrid(f, grid) = begin
        result = deepcopy(grid)
        for m in eachmatch(r"(.*) (\d+),(\d+) through (\d+),(\d+)", input)
            (op, startx, starty, endx, endy) = m.captures
            (sx, sy) = [parse(Int, x) + 1 for x in (startx, starty)]
            (ex, ey) = [parse(Int, x) + 1 for x in (endx, endy)]
            for y in sy:ey, x in sx:ex
                result[y, x] = f(op, result[y, x])
            end
        end
        result
    end

    partone = mapgrid(fill(false, (1000, 1000))) do op, val
        if op == "turn off" 0 elseif op == "turn on" 1 else !val end
    end |> count

    parttwo = mapgrid(fill(0, (1000, 1000))) do op, val
        if op == "turn off" max(0, val - 1) elseif op == "turn on" val + 1 else val + 2 end
    end |> sum

    partone, parttwo
end

@time @show solve()
