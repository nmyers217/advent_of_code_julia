struct Food
    ingredients::Vector{AbstractString}
    allergens::Vector{AbstractString}

    Food(str::AbstractString) = begin
        (ingredients, allergens) = match(r"(.+) \(contains (.+)\)", str).captures
        new(split(ingredients), split(allergens, ", "))
    end
end

const FoodList = Vector{Food}
function FoodList(str::AbstractString)::FoodList
    Food.(split(strip(str), "\n"))
end

const AllergenMapping = Dict{AbstractString,Set{AbstractString}}
function possible_allergens(foods::FoodList)::AllergenMapping
    result = Dict()
    for food in foods, a in food.allergens
        ings = Set(food.ingredients)
        result[a] = intersect(get!(result, a, ings), ings)
    end
    result
end

function canonical_boring_problem!(am::AllergenMapping)
    solved_ingredients = union([v for (k, v) in am if length(v) == 1]...)
    unsolved_allergens = [k for (k, v) in am if length(v) > 1]

    # Process continually removing cyclical dependencies as we go
    while length(unsolved_allergens) > 0
        for u in unsolved_allergens
            am[u] = setdiff(am[u], solved_ingredients)
            if length(am[u]) == 1
                push!(solved_ingredients, first(am[u]))
            end
        end
        unsolved_allergens = [k for (k, v) in am if length(v) > 1]
    end

    join([first(am[k]) for k in sort(collect(keys(am)))], ",")
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    list = FoodList(input)
    allergen_mapping = possible_allergens(list)

    part_one = begin
        allergens = union(values(allergen_mapping)...)
        sum(count(i -> i ∉ allergens, f.ingredients) for f in list)
    end

    part_two = canonical_boring_problem!(allergen_mapping)

    part_one, part_two
end

@time @show solve()
