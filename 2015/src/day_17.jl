using Pkg
Pkg.add("Combinatorics")
using Combinatorics

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    containers = [parse(Int, str) for str in split(strip(input), "\n")]
    combos = [c for c in combinations(containers) if sum(c) == 150]
    length(combos), count(c -> length(c) == minimum(length, combos), combos)
end

@time solve()
