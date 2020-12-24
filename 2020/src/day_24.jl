
const Path = AbstractString
parse_input(str::AbstractString)::Vector{Path} = split(strip(str), "\n")

function next(p::Path)::Tuple{Union{Symbol,Nothing},Path}
    if isempty(p)
        nothing, p
    else
        if p[1] in ['s', 'n']
            Symbol(p[1:2]), p[3:end]
        else
            Symbol(p[1:1]), p[2:end]
        end
    end
end

const dirs = [:e, :se, :sw, :w, :nw, :ne]
const neighbors = [
    [-1, 1, 0],
    [0, 1, -1],
    [1, 0, -1],
    [1, -1, 0],
    [0, -1, 1],
    [-1, 0, 1]
]
function delta(dir::Symbol)::Vector{Int}
    Dict(d => vec for (d, vec) in zip(dirs, neighbors))[dir]
end

const Grid = Dict{Vector{Int},Symbol}

function initial_pattern(paths::Vector{Path})::Grid
    points = Dict()

    for p in paths
        cur_loc, cur_path = [0, 0, 0], p

        while !isempty(cur_path)
            dir, rest = next(cur_path)
            cur_loc += delta(dir)
            cur_path = rest
        end

        if haskey(points, cur_loc)
            cur_color = points[cur_loc]
            points[cur_loc] = cur_color == :white ? :black : :white
        else
            points[cur_loc] = :black
        end
    end

    points
end


function hexagonal_conway(points::Grid, generations=100)::Grid
    cur = points

    for _ in 1:generations
        next = deepcopy(cur)

        # We will need to process points that contain a black tile
        queue = Set(p for (p, c) in cur if c == :black)
        for p in queue
            # We will also process all of their neighbors
            push!(queue, [p + delta for delta in neighbors]...)
        end

        while !isempty(queue)
            p = pop!(queue)
            ns = [p + delta for delta in neighbors]
            blacks = count(n -> haskey(cur, n) && cur[n] == :black, ns)

            if get!(cur, p, :white) == :black
                if blacks == 0 || blacks > 2
                    next[p] = :white
                end
            else
                if blacks == 2
                    next[p] = :black
                end
            end
        end

        cur = next
    end

    cur
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    paths = parse_input(input)
    points = initial_pattern(paths)

    part_one = count(==(:black), values(points))

    points = hexagonal_conway(points)
    part_two = count(==(:black), values(points))

    part_one, part_two
end

@time @show solve()
