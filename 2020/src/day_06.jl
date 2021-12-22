function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    groups = map(split(input, "\n\n")) do group
        [split(person, "") for person in split(group, "\n")]
    end
    (part_one, part_two) = map([union, intersect]) do fn
        sum([(length ∘ fn)(g...) for g in groups])
    end
    (part_one, part_two)
end

@time @show solve()
