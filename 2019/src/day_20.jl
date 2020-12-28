const dirs = [CartesianIndex(y, x) for (x, y) in [[0, -1], [1, 0], [0, 1], [-1, 0]]]
const Grid = Array{Char,2}
const PortalCache = Dict{Set{Char},Dict{CartesianIndex{2},Symbol}}

function Grid(str::AbstractString)::Grid
    lines = split(str, "\n", keepempty=false)
    rows, cols = length(lines), maximum(length, lines)
    result = fill(' ', (rows, cols))
    for (y, row) in enumerate(lines), (x, c) in enumerate(row)
        result[y, x] = c
    end
    result
end

function PortalCache(grid::Grid)::PortalCache
    result = Dict()
    for i in CartesianIndices(grid)
        if grid[i] != '.'
            continue
        end

        letters = [d for d in dirs if grid[i + d] in 'A':'Z']

        if isempty(letters)
            continue
        end

        # Figure out if this point is on the outside or inside of the donut
        y, x = Tuple(i)
        rows, cols = size(grid, 1), size(grid, 2)
        location = y <= 3 || y >= rows - 2 || x <= 3 || x >= cols - 2 ? :outside : :inside

        key = Set([grid[i + letters[1]], grid[i + letters[1] * 2]])
        get!(result, key, Dict())[i] = location
    end
    result
end

function bfs(grid::Grid, pc::PortalCache)
    source = first(pc[Set(['A'])])[1]
    target = first(pc[Set(['Z'])])[1]
    prev = Dict()
    visited = Set([source])
    q = [source]

    while !isempty(q)
        cur = popfirst!(q)

        if cur == target
            break
        end

        for d in dirs
            neighbor = cur + d

            if grid[neighbor] == '#'
                continue
            end

            next = if grid[neighbor] in 'A':'Z'
                portal = Set([grid[neighbor], grid[neighbor + d]])
                if portal in [Set(['A']), Set(['Z'])]
                    continue
                end
                first(setdiff(keys(pc[portal]), Set([cur])))
            else
                neighbor
            end

            if next in visited
                continue
            end

            prev[next] = cur
            push!(visited, next)
            push!(q, next)
        end
    end

    path = []
    node = target
    while haskey(prev, node)
        push!(path, node)
        node = prev[node]
    end
    length(path)
end

function dimensional_bfs(grid::Grid, pc::PortalCache)
    source = (first(pc[Set(['A'])])[1], 0)
    target = (first(pc[Set(['Z'])])[1], 0)
    prev = Dict()
    visited = Set([source])
    q = [source]

    while !isempty(q)
        (cur, level) = popfirst!(q)

        if (cur, level) == target
            break
        end

        for d in dirs
            neighbor = cur + d

            if grid[neighbor] == '#'
                continue
            end

            (next, nextlevel) = if grid[neighbor] in 'A':'Z'
                portal = Set([grid[neighbor], grid[neighbor + d]])
                if portal in [Set(['A']), Set(['Z'])]
                    continue
                end
                points = pc[portal]
                if level == 0 && points[cur] == :outside
                    continue
                end
                next = first(setdiff(keys(pc[portal]), Set([cur])))
                nextlevel = points[next] == :outside ? level - 1 : level + 1
                next, nextlevel
            else
                neighbor, level
            end

            if (next, nextlevel) in visited
                continue
            end

            prev[(next, nextlevel)] = (cur, level)
            push!(visited, (next, nextlevel))
            push!(q, (next, nextlevel))
        end
    end

    path = []
    node = target
    while haskey(prev, node)
        push!(path, node)
        node = prev[node]
    end
    length(path)
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    grid = Grid(input)
    portalcache = PortalCache(grid)
    bfs(grid, portalcache), dimensional_bfs(grid, portalcache)
end

@time @show solve()
