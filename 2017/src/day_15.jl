function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    prev = [parse(UInt64, split(line, " ")[end]) for line in split(strip(input), "\n")]
    numpairs = 40_000_000
    factors, divisor = (16807, 48271), 2147483647

    partone = begin
        matches = 0
        for _ in 1:numpairs
            for (i, p) in enumerate(prev)
                prev[i] = p * factors[i] % divisor
            end

            if (prev[1] << (6 * 8)) == (prev[2] << (6 * 8))
                matches += 1
            end
        end
        matches
    end

    prev = [parse(UInt64, split(line, " ")[end]) for line in split(strip(input), "\n")]
    numpairs = 5_000_000

    parttwo = begin
        found, queues, multiples = [0, 0], ([], []), (4, 8)

        while found[1] < numpairs || found[2] < numpairs
            for (i, p) in enumerate(prev)
                if prev[i] % multiples[i] == 0 && found[i] < numpairs
                    found[i] += 1
                    push!(queues[i], prev[i])
                end

                prev[i] = p * factors[i] % divisor
            end
        end

        eq((a, b)) = a << (6 *8) == b << (6 * 8)
        count(eq, zip(queues...))
    end

    partone, parttwo
end

@time solve()
