struct Tile
    id::Int
    data::Array{Char,2}

    Tile(id::Int, data::Array{Char,2}) = new(id, data)
    Tile(str::AbstractString) = begin
        lines = split(strip(str), "\n")
        id = parse(Int, first(match(r"Tile (\d+):", lines[1]).captures))
        data = fill('.', (10, 10))
        for (y, row) in enumerate(lines[2:end])
            for (x, str) in enumerate(split(row, ""))
                data[y, x] = str[1]
            end
        end
        new(id, data)
    end
end

rotate(t::Tile)::Tile = Tile(t.id, rotr90(t.data))
flip(t::Tile)::Tile = Tile(t.id, reverse(t.data, dims=1))
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
                for t2′ in [t2, flip(t2)]
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

const Image = Array{Char,2}

function Image(g::TileGraph)::Image
    topleft = first(g[k] for (k, v) in g if isnothing(v.left) && isnothing(v.down))
    row_node = topleft

    matrix = nothing
    while true
        row = flip(row_node.val).data[2:end - 1, 2:end - 1]

        col_node = row_node
        while !isnothing(col_node.right)
            col_node = g[col_node.right]
            row = hcat(row, flip(col_node.val).data[2:end - 1, 2:end - 1])
        end

        matrix = isnothing(matrix) ? row : vcat(matrix, row)

        if isnothing(row_node.up)
            break
        end
        row_node = g[row_node.up]
    end
    matrix
end

function find_monsters(i::Image)::Set{Vector{Int}}
    # A series of vectors that will trace from one part of a monster to the next
    monster_deltas = [
        # Tail
        [0, 0], [1, 1],
        # Hump 1
        [3, 0], [1, -1], [1, 0], [1, 1],
        # Hump 2
        [3, 0], [1, -1], [1, 0], [1, 1],
        # Head
        [3, 0], [1, -1], [1, -1], [0, 1], [1, 0]
    ]

    result = Set()
    (rows, cols) = size(i, 1), size(i, 2)
    for y in 1:rows, x in 1:cols
        if i[y, x] == '.'
            continue
        end

        points = []
        cur = [x, y]
        for delta in monster_deltas
            cur += delta
            (Δx, Δy) = cur
            if !(1 <= Δx <= cols && 1 <= Δy <= rows) || i[Δy, Δx] != '#'
                break
            end
            push!(points, cur)
        end

        if length(points) == length(monster_deltas)
            push!(result, points...)
        end
    end
    result
end

function find_roughness(image::Image)
    i = image
    for _ in 1:4
        i = rotr90(i)
        for c in [i, reverse(i, dims=1)]
            monsters = find_monsters(c)
            if length(monsters) > 0
                return count(==('#'), i) - length(monsters)
            end
        end
    end
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    graph = TileGraph(input)
    part_one = begin
        corners = [
            k for (k, v) in graph
            if count(isnothing, [v.up, v.down, v.left, v.right]) == 2
        ]
        prod(corners)
    end
    part_two = find_roughness(Image(graph))
    part_one, part_two
end

@time solve()
