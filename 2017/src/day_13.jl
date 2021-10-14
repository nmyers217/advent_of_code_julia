function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    scanners = map(split(strip(input), "\n")) do line
        tuple([parse(Int, s) for s in split(strip(line), ": ")]...)
    end

    caught(delay, (depth, range)) = (delay + depth) % (2 * (range - 1)) == 0

    partone = sum(prod(s) for s in scanners if caught(0, s))

    parttwo = begin
        delay = 0
        while true
            if all(s -> !caught(delay, s), scanners) break end
            delay += 1
        end
        delay
    end

    partone, parttwo
end

@time solve()
