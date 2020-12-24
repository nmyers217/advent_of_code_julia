
const dirs = Dict(
    "e" => [-1, 1, 0], "se" => [0, 1, -1], "sw" => [1, 0, -1],
    "w" => [1, -1, 0], "nw" => [0, -1, 1], "ne" => [-1, 0, 1]
)

const Path = Vector{Vector{Int}}
function parse_input(str::AbstractString)::Vector{Path}
    lines = split(strip(str), "\n")
    matches = (collect ∘  eachmatch).(r"e|w|ne|nw|se|sw", lines)
    [(rm -> dirs[rm.match]).(line) for line in matches]
end

const Grid = Dict{Vector{Int},Symbol}
function initial_pattern(paths::Vector{Path})::Grid
    points = Dict()
    for point in [reduce(+, path, init=[0,0,0]) for path in paths]
        color = get!(points, point, :white)
        points[point] = color == :white ? :black : :white
    end
    points
end


function hexagonal_conway(points::Grid, generations=100)::Grid
    cur = points

    for _ in 1:generations
        next = deepcopy(cur)

       # We will need to process points that contain a black tile
        process_these = Set(p for (p, c) in cur if c == :black)
        for p in process_these
           # We will also process all of their neighbors
            push!(process_these, [p + delta for delta in values(dirs)]...)
        end

        for p in process_these
            ns = [p + delta for delta in values(dirs)]
            blacks = count(n -> haskey(cur, n) && cur[n] == :black, ns)
            color = get!(cur, p, :white)

            if color == :black && (blacks == 0 || blacks > 2)
                next[p] = :white
            elseif color == :white && blacks == 2
                next[p] = :black
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
    part_two = count(==(:black), points |> hexagonal_conway |> values)
    part_one, part_two
end

@time @show solve()
