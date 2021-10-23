const Components = Dict{Int64, Set{Int64}}
const Bridge = Vector{Tuple{Int64, Int64}}

function parsecomponents(input)::Components
    result = Dict()
    for line in split(strip(input), "\n")
        (left, right) = [parse(Int, str) for str in split(strip(line), "/")]
        push!(get!(result, left, Set()), right)
        push!(get!(result, right, Set()), left)
    end
    result
end

function reducebridges(f, bridge::Bridge, components::Components; init=0)
    result, right = init, last(last(bridge))
    for left in components[right]
        if (right, left) in bridge || (left, right) in bridge
            continue
        end
        next::Bridge = [bridge; (right, left)]
        result = reducebridges(f, next, components; init=f(result, next))
    end
    result
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    components = parsecomponents(input)

    strength(bridge::Bridge) = sum(sum.(bridge))

    partone = reducebridges([(0,0)], components) do strongest, bridge
        max(strongest, strength(bridge))
    end

    parttwo = reducebridges([(0,0)], components; init=[]) do strongestlongest, bridge
        if length(bridge) < length(strongestlongest)
            strongestlongest
        elseif length(bridge) > length(strongestlongest)
            bridge
        else
            strength(bridge) > strength(strongestlongest) ? bridge : strongestlongest
        end
    end |> strength

    partone, parttwo
end

@time solve()
