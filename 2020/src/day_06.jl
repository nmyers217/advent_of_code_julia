struct Person
    yesses::Set{Char}
    Person(str::AbstractString) = new(Set([s[1] for s in split(str, "")]))
end

function solve()
    input = strip(read("2020/res/day_06.txt", String))
    groups = [map(Person, split(group, "\n")) for group in split(input, "\n\n")]

    part_one = begin
        yes_counts = map(groups) do group
            length(union([person.yesses for person in group]...))
        end
        sum(yes_counts)
    end

    part_two = begin
        all_yes_counts = map(groups) do group
            length(intersect([person.yesses for person in group]...))
        end
        sum(all_yes_counts)
    end

    (part_one, part_two)
end

solve()