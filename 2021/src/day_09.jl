function getheightmap(input)
    arr = map(split(strip(input), "\n")) do line
        parse.(Int, first.(split(strip(line), "")))
    end
    result = fill(0, (arr |> length, arr |> first |> length))
    for (y, row) in enumerate(arr)
        for (x, col) in enumerate(row)
            result[y, x] = col
        end
    end
    result
end

function getneighbors((y, x), matrix)
    (rows, cols) = size(matrix)
    dirs = [(-1, 0), (0, 1), (1, 0), (0, -1)]
    result = []
    for d in dirs
        (ny, nx) = (y, x) .+ d
        if ny < 1 || ny > rows || nx < 1 || nx > cols continue end
        push!(result, (ny, nx))
    end
    result
end

function getlowpoints(heightmap)
    result = []
    (rows, cols) = size(heightmap)
    for y in 1:rows, x in 1:cols
        islowpoint = all(getneighbors((y, x), heightmap)) do (ny, nx)
            heightmap[y, x] < heightmap[ny, nx]
        end
        if islowpoint
            push!(result, (y, x))
        end
    end
    result
end

function bfs(point, heightmap)
    queue = [point]
    seen = Set([point])
    while !isempty(queue)
        (y, x) = popfirst!(queue)
        for (ny, nx) in getneighbors((y, x), heightmap)
            if heightmap[ny, nx] < 9 && (ny, nx) ∉ seen
                push!(queue, (ny, nx))
                push!(seen, (ny, nx))
            end
        end
    end
    seen
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    heightmap = getheightmap(input)
    lowpoints = getlowpoints(heightmap)

    partone = sum([heightmap[y, x] for (y, x) in lowpoints] .+ 1)

    parttwo = begin
        sizes = [bfs((y, x), heightmap) |> length for (y, x) in lowpoints]
        reverse(sort(sizes))[1:3] |> prod
    end

    partone, parttwo
end

@time solve()