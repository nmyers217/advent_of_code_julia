import Base.show

const TILE_SIZE = 10

struct Tile
    id::Int
    data::Array{Char,2}

    Tile(id::Int, data::Array{Char,2}) = new(id, data)
    Tile(str::AbstractString) = begin
        lines = split(strip(str), "\n")
        id = parse(Int, first(match(r"Tile (\d+):", lines[1]).captures))
        data = fill('.', (TILE_SIZE, TILE_SIZE))
        for (y, row) in enumerate(lines[2:end])
            for (x, str) in enumerate(split(row, ""))
                data[y, x] = str[1]
            end
        end
        new(id, data)
    end
end

function show(io::IO, t::Tile, id=false)
    if id
        println(io, "Tile $(t.id):")
    end
    for y in axes(t.data, 1)
        for x in axes(t.data, 2)
            print(io, t.data[y, x])
        end
        print(io, "\n")
    end
end

rotate(t::Tile)::Tile = Tile(t.id, rotr90(t.data))
flipy(t::Tile)::Tile = Tile(t.id, reverse(t.data, dims=2))
flipx(t::Tile)::Tile = Tile(t.id, reverse(t.data, dims=1))
borders(t::Tile)::Dict{Symbol,Vector{Char}} = begin
    result = Dict()
    result[:up] = t.data[1, :]
    result[:down] = t.data[end, :]
    result[:left] = t.data[:, 1]
    result[:right] = t.data[:, end]
    result
end

mutable struct Node
    up::Union{Nothing,Int}
    down::Union{Nothing,Int}
    left::Union{Nothing,Int}
    right::Union{Nothing,Int}
    val::Tile
    Node(t::Tile) = new(nothing, nothing, nothing, nothing, t)
end

const TileGraph = Dict{Int,Node}

function TileGraph(str::AbstractString)::TileGraph
    tiles = Tile.(split(strip(str), "\n\n"))

    result = Dict(t.id => Node(t) for t in tiles)

    q = [first(tiles).id]
    while !isempty(q)
        id1 = popfirst!(q)
        node1 = result[id1]
        t1 = node1.val
        bs1 = borders(t1)

        for (id2, node2) in result
            if id1 == id2
                continue
            end

            t2 = node2.val
            for rot in 1:4
                t2 = rotate(t2)
                for t2′ in [t2, flipy(t2), flipx(t2)]
                    bs2 = borders(t2′)

                    if isnothing(node1.right) && bs1[:right] == bs2[:left]
                        node1.right = t2′.id
                        node2.left = t1.id
                        node2.val = t2′
                        push!(q, t2′.id)
                    elseif isnothing(node1.left) && bs1[:left] == bs2[:right]
                        node1.left = t2′.id
                        node2.right = t1.id
                        node2.val = t2′
                        push!(q, t2′.id)
                    elseif isnothing(node1.up) && bs1[:up] == bs2[:down]
                        node1.up = t2′.id
                        node2.down = t1.id
                        node2.val = t2′
                        push!(q, t2′.id)
                    elseif isnothing(node1.down) && bs1[:down] == bs2[:up]
                        node1.down = t2′.id
                        node2.up = t1.id
                        node2.val = t2′
                        push!(q, t2′.id)
                    end
                end
            end
        end
    end

    result
end

function solve()
    input = read("2020/res/day_20.txt", String)
    test_input = """
    Tile 2311:
    ..##.#..#.
    ##..#.....
    #...##..#.
    ####.#...#
    ##.##.###.
    ##...#.###
    .#.#.#..##
    ..#....#..
    ###...#.#.
    ..###..###

    Tile 1951:
    #.##...##.
    #.####...#
    .....#..##
    #...######
    .##.#....#
    .###.#####
    ###.##.##.
    .###....#.
    ..#.#..#.#
    #...##.#..

    Tile 1171:
    ####...##.
    #..##.#..#
    ##.#..#.#.
    .###.####.
    ..###.####
    .##....##.
    .#...####.
    #.##.####.
    ####..#...
    .....##...

    Tile 1427:
    ###.##.#..
    .#..#.##..
    .#.##.#..#
    #.#.#.##.#
    ....#...##
    ...##..##.
    ...#.#####
    .#.####.#.
    ..#..###.#
    ..##.#..#.

    Tile 1489:
    ##.#.#....
    ..##...#..
    .##..##...
    ..#...#...
    #####...#.
    #..#.#.#.#
    ...#.#.#..
    ##.#...##.
    ..##.##.##
    ###.##.#..

    Tile 2473:
    #....####.
    #..#.##...
    #.##..#...
    ######.#.#
    .#...#.#.#
    .#########
    .###.#..#.
    ########.#
    ##...##.#.
    ..###.#.#.

    Tile 2971:
    ..#.#....#
    #...###...
    #.#.###...
    ##.##..#..
    .#####..##
    .#..####.#
    #..#.#..#.
    ..####.###
    ..#.#.###.
    ...#.#.#.#

    Tile 2729:
    ...#.#.#.#
    ####.#....
    ..#.#.....
    ....#..#.#
    .##..##.#.
    .#.####...
    ####.#.#..
    ##.####...
    ##..#.##..
    #.##...##.

    Tile 3079:
    #.#.#####.
    .#..######
    ..#.......
    ######....
    ####.#..#.
    .#...#.##.
    #.#####.##
    ..#.###...
    ..#.......
    ..#.###...
    """
    graph = TileGraph(input)
    part_one = begin
        corners = [
            k for (k, v) in graph
            if count(isnothing, [v.up, v.down, v.left, v.right]) == 2
        ]
        prod(corners)
    end
    graph
end

@time solve()