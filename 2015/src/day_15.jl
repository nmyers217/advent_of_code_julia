using Pkg
Pkg.add("DataStructures")
using DataStructures

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    ingredients = reduce(eachmatch(r"(\w+): (.*)", input), init=Dict()) do acc, m
        (name, attributes) = m.captures
        acc[name] = reduce(split(strip(attributes), ","), init=Dict()) do acc, attr
            (k, v) = split(strip(attr), " ")
            acc[k] = parse(Int, v)
            acc
        end
        acc
    end

    scoreattribute(recipe, attr) =
        sum(ingredients[ing][attr] * teaspoons for (ing, teaspoons) in recipe)

    scorerecipe(recipe) = reduce(["capacity", "durability", "flavor", "texture"], init=1) do acc, attr
        acc * max(scoreattribute(recipe, attr), 0)
    end

    reducerecipes(f; init=0) = begin
        result = init
        for a in 0:100, b in 0:100, c in 0:100, d in 0:100
            if a + b + c + d != 100; continue end
            recipe = Dict(k => v for (k, v) in zip(keys(ingredients), [a,b,c,d]))
            result = f(result, recipe)
        end
        result
    end

    partone = reducerecipes() do acc, recipe
        score = scorerecipe(recipe)
        score > acc ? score : acc
    end

    parttwo = reducerecipes() do acc, recipe
        score = scorerecipe(recipe)
        scoreattribute(recipe, "calories") == 500 && score > acc ? score : acc
    end

    partone, parttwo
end

@time solve()
