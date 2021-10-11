function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    partone, parttwo = 0, 0

    for row in split(strip(input), "\n")
        vals = [parse(Int, str) for str in split(row, "\t")]
        (smallest, largest) = extrema(vals)
        partone += largest - smallest

        for a in vals, b in vals
            if a === b continue end
            diva, divb = (a / b), (b / a)
            if diva * 100 % 100 == 0 parttwo += diva; break end
            if divb * 100 % 100 == 0 parttwo += divb; break end
        end
    end

    partone, parttwo
end

@time solve()
