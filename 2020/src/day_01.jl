function part_one(entries::Vector{Int})
    for a in entries, b in entries
        if allunique([a, b]) && a + b == 2020
            return a * b
        end
    end
end

function part_two(entries::Vector{Int})
    for a in entries, b in entries, c in entries
        if allunique([a, b, c]) && a + b + c == 2020
            return a * b * c
        end
    end
end

function solve()
    input = read("2020/res/day_01.txt", String)
    entries = [parse(Int, x) for x in split(input, "\n")]
    (part_one(entries), part_two(entries))
end

solve()
