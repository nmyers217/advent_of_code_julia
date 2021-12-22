function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    positions = parse.(Int, split(strip(input), ","))

    solve(f) = begin
        (start, stop) = extrema(positions)
        minimum(sum(f.(positions, target)) for target in start:stop)
    end

    distance(p, target) = abs(p - target)
    sumcost(p, target) = sum(1:distance(p, target))

    solve(distance), solve(sumcost)
end

@time @show solve()