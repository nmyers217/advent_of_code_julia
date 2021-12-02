function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    partone, parttwo, aim = (0, 0), (0, 0), 0

    for m in eachmatch(r"(\w+) (\d+)", input)
        (dir, magstr) = m.captures
        mag = parse(Int, magstr)

        if dir == "down"
            partone = partone .+ (0, 1) .* mag
            aim += mag
        elseif dir == "up"
            partone = partone .+ (0, -1) .* mag
            aim -= mag
        elseif dir == "forward"
            partone = partone .+ (1, 0) .* mag
            parttwo = parttwo .+ (mag, aim * mag)
        end
    end

    prod(partone), prod(parttwo)
end

@time solve()
