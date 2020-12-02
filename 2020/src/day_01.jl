function part_one(entries)
    for a in entries
        for b in entries
            if a != b && a + b == 2020
                return (a, b)
            end
        end
    end
end

function part_two(entries)
    for a in entries
        for b in entries
            for c in entries
                if a != b != c && a + b + c == 2020
                    return (a, b, c)
                end
            end
        end
    end
end

function solve()
    input = read("2020/res/day_01.txt", String)
    entries = [parse(Int, x) for x in split(input, "\n")]

    (a, b) = part_one(entries)
    (a2, b2, c2) = part_two(entries)

    (a * b, a2 * b2 * c2)
end

solve()
