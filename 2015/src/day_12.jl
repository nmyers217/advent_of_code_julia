using Pkg
Pkg.add("JSON")
import JSON

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    json = JSON.parse(input)

    reducejson(f, json; init=0, countred=true) = begin
        t = typeof(json)
        if !(t <: AbstractDict || t <: AbstractVector || t <: AbstractArray)
            return json
        end

        if !countred && t <: AbstractDict && "red" in values(json)
            return init
        end

        vals = [reducejson(f, val, init=init, countred=countred) for val in values(json)]
        reduce(f, vals, init=init)
    end

    reducer(acc, val) = typeof(val) <: Int64 ? acc + val : acc

    reducejson(reducer, json, init=0), reducejson(reducer, json, init=0, countred=false)
end

@time solve()
