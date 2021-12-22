struct Schedule
    start::Int
    busses::Vector{Int}
    offsets::Vector{Int}

    Schedule(str::AbstractString) = begin
        (start_str, busses_str) = split(strip(str), "\n")
        ids = split(busses_str, ",")
        busses = [parse(Int, c) for c in ids if c != "x"]
        offsets = [i - 1 for (i, c) in enumerate(ids) if c != "x"]
        new(parse(Int, start_str), busses, offsets)
    end
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    s = Schedule(input)

    part_one = begin
        waits = s.busses - s.start .% s.busses
        i = argmin(waits)
        s.busses[i] * waits[i]
    end

    part_two = begin
        # Use chinese remainder theorem
        p = BigInt(prod(s.busses))
        s = sum(ai * invmod(p ÷ ni, ni) * p ÷ ni for (ni, ai) in zip(s.busses, -s.offsets))
        mod(s, p)
    end

    part_one, part_two
end

@time @show solve()
