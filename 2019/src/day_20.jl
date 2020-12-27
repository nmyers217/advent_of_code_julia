input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

test_input = """
                   A
                   A
  #################.#############
  #.#...#...................#.#.#
  #.#.#.###.###.###.#########.#.#
  #.#.#.......#...#.....#.#.#...#
  #.#########.###.#####.#.#.###.#
  #.............#.#.....#.......#
  ###.###########.###.#####.#.#.#
  #.....#        A   C    #.#.#.#
  #######        S   P    #####.#
  #.#...#                 #......VT
  #.#.#.#                 #.#####
  #...#.#               YN....#.#
  #.###.#                 #####.#
DI....#.#                 #.....#
  #####.#                 #.###.#
ZZ......#               QG....#..AS
  ###.###                 #######
JO..#.#.#                 #.....#
  #.#.#.#                 ###.#.#
  #...#..DI             BU....#..LF
  #####.#                 #.#####
YN......#               VT..#....QG
  #.###.#                 #.###.#
  #.#...#                 #.....#
  ###.###    J L     J    #.#.###
  #.....#    O F     P    #.#...#
  #.###.#####.#.#####.#####.###.#
  #...#.#.#...#.....#.....#.#...#
  #.#####.###.###.#.#.#########.#
  #...#.#.....#...#.#.#.#.....#.#
  #.###.#####.###.###.#.#.#######
  #.#.........#...#.............#
  #########.###.###.#############
           B   J   C
           U   P   P
"""

function solve()
    grid = begin
        lines = split(input, "\n", keepempty=false)
        rows, cols = length(lines), maximum(length, lines)
        result = fill(' ', (rows, cols))
        for (y, row) in enumerate(lines), (x, c) in enumerate(row)
            result[y, x] = c
        end
        result
    end

    dirs = [CartesianIndex(y, x) for (x, y) in [[0, -1], [1, 0], [0, 1], [-1, 0]]]
    portalcache = begin
        result = Dict()
        for i in CartesianIndices(grid)
            if grid[i] != '.'
                continue
            end

            letters = [d for d in dirs if grid[i + d] in 'A':'Z']

            if isempty(letters)
                continue
            end

            key = Set([grid[i + letters[1]], grid[i + letters[1] * 2]])
            push!(get!(result, key, Set()), i)
        end
        result
    end

    source = first(portalcache[Set(['A'])])
    target = first(portalcache[Set(['Z'])])
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

            # push!(visited, neighbor)
            next = if grid[neighbor] in 'A':'Z'
                portal = Set([grid[neighbor], grid[neighbor + d]])
                if portal in [Set(['A']), Set(['Z'])]
                    continue
                end
                first(setdiff(portalcache[portal], Set([cur])))
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
    node = first(portalcache[Set(['Z'])])
    while haskey(prev, node)
        push!(path, node)
        node = prev[node]
    end
    length(path)
end

@time @show solve()
