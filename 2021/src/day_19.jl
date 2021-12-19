using Pkg
Pkg.add("DataStructures")
Pkg.add("LinearAlgebra")
Pkg.add("Combinatorics")
using DataStructures, LinearAlgebra, Combinatorics

function getrotationmatrices()
    result = []
    for x in [-1 1], y in [-1 1], z in [-1, 1]
        for q in permutations([[x 0 0], [0 y 0], [0 0 z]])
            m = reduce(vcat, q)
            if det(m) == 1
                # NOTE: a determinant of 1 indicates the matrix is a suitable permutation matrix
                push!(result, m)
            end
        end
    end
    return result
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    scanners = begin
        result = Dict{Int64,Vector{Vector{Int64}}}()
        for (id, paragraph) in enumerate(split(strip(input), "\n\n"))
            result[id - 1] = map(split(paragraph, "\n")[2:end]) do line
                parse.(Int, split(strip(line), ","))
            end
        end
        result
    end

    rots = getrotationmatrices()
    id = [1 0 0; 0 1 0; 0 0 1]
    absolutebeacons = Set([i' * id for i in scanners[0]])
    remaining = filter(x -> x != 0, keys(scanners))
    scannerpositions = [[0 0 0]]

    while length(remaining) > 0
        for scanner in remaining
            for rotmat in rots
                rotated = [i' * rotmat for i in scanners[scanner]]
                counts = sort(
                    collect(counter([j - i for i in rotated for j in absolutebeacons])),
                    by=x -> x[2],
                    rev=true
                )
                if counts[1][2] >= 12
                    union!(absolutebeacons, [i + counts[1][1] for i in rotated])
                    filter!(x -> x != scanner, remaining)
                    push!(scannerpositions, counts[1][1])
                    break
                end
            end
        end
    end

    partone = length(unique(absolutebeacons))
    parttwo = maximum([sum(abs.(i-j)) for i in scannerpositions for j in scannerpositions])

    partone, parttwo
end

@time solve()