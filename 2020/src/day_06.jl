function solve()
    input = strip(read("2020/res/day_06.txt", String))
    groups = map(split(input, "\n\n")) do group
        [split(person, "") for person in split(group, "\n")]
    end
    part_one = sum(map(g -> length(union(g...)), groups))
    part_two = sum(map(g -> length(intersect(g...)), groups))
    (part_one, part_two)
end

solve()