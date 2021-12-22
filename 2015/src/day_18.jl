function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    # input = """
    # ##.#.#
    # ...##.
    # #....#
    # ..#...
    # #.#..#
    # ####.#
    # """

    grid() = begin
        vecofvecs = [first.(split(strip(line), "")) for line in split(strip(input), "\n")]
        dims = (length(vecofvecs), length(first(vecofvecs)))
        result = fill('.', dims)
        for y in 1:dims[1], x in 1:dims[2]
            result[y, x] = vecofvecs[y][x]
        end
        result
    end

    getcorners(grid) = begin
        (miny, maxy), (minx, maxx) = extrema(axes(grid, 1)), extrema(axes(grid, 2))
        [(miny, minx), (miny, maxx), (maxy, minx), (maxy, maxx)]
    end

    mapconway(f, grid, cornerslocked) = begin
        directions = [
            (-1, -1), (-1, 0), (-1, 1),
            ( 0, -1),          ( 0, 1),
            ( 1, -1), ( 1, 0), ( 1, 1),
        ]
        corners = getcorners(grid)

        result = deepcopy(grid)
        for y in axes(grid, 1), x in axes(grid, 2)
            if cornerslocked && (y, x) in corners continue end

            neighbors = reduce(directions, init=[]) do acc, dir
                (ny, nx) = (y, x) .+ dir
                if ny in axes(grid, 1) && nx in axes(grid, 2)
                    push!(acc, grid[ny, nx])
                end
                acc
            end

            result[y, x] = f(grid[y, x] == '#', count(==('#'), neighbors))
        end
        result
    end

    nextgrid(grid; cornerslocked=false) = mapconway(grid, cornerslocked) do on, neighborson
        if on
            neighborson in [2, 3] ? '#' : '.'
        else
            neighborson == 3 ? '#' : '.'
        end
    end

    partone = begin
        final = reduce((g, _) -> nextgrid(g), 1:100, init=grid())
        count(==('#'), final)
    end

    parttwo = begin
        g = grid()
        for (y, x) in getcorners(g)
            g[y, x] = '#'
        end
        final = reduce((g, _) -> nextgrid(g; cornerslocked=true), 1:100, init=g)
        count(==('#'), final)
    end

    partone, parttwo
end

@time @show solve()
