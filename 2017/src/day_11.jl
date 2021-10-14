# https://www.redblobgames.com/grids/hexagons/#coordinates-axial
const axialmovedict = Dict(
    "nw" => (-1, +0), "n" => (+0, -1), "ne" => (+1, -1),
    "sw" => (-1, +1), "s" => (+0, +1), "se" => (+1, +0),
)

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    distfromorigin(axial) = maximum(abs.(axial))

    loc, seen = (0, 0), Set()
    for move in [axialmovedict[s] for s in split(strip(input), ",")]
        push!(seen, loc)
        loc = loc .+ move
    end

    distfromorigin(loc), maximum(distfromorigin.(seen))
end

@time solve()
