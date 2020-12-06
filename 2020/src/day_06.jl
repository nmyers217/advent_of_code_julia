function solve()
    input = strip(read("2020/res/day_06.txt", String))
    groups = map(split(input, "\n\n")) do group
        [split(person, "") for person in split(group, "\n")]
    end
    (part_one, part_two) = map([union, intersect]) do fn
        sum([(length ∘ fn)(g...) for g in groups])
    end
    (part_one, part_two)
end

solve()