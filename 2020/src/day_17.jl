using Test

const Conway = Dict{Vector{Int},Bool}

function Conway(str::AbstractString; dims=3)::Conway
    result = Dict()
    for (y, line) in enumerate(split(strip(str), "\n"))
        for (x, state) in enumerate(split(line, ""))
            if state == "#"
                if dims == 3
                    result[[x, y, 0]] = true
                elseif dims == 4
                    result[[x, y, 0, 0]] = true
                else
                    error("Unssuported number of dimensions $dims")
                end
            end
        end
    end
    result
end

"""
    We could probably make this function generic for any n dimensions
    but copy/paste was quicker
"""
function neighbors(v::Vector{Int}; dims=3)::Vector{Vector{Int}}
    result = []
    if dims == 3
        (x, y, z) = v
        for nx in x - 1:x + 1, ny in y - 1:y + 1, nz in z - 1:z + 1
            if [nx, ny, nz] != [x, y, z]
                push!(result, [nx, ny, nz])
            end
        end
    elseif dims == 4
        (x, y, z, w) = v
        for nx in x - 1:x + 1, ny in y - 1:y + 1, nz in z - 1:z + 1, nw in w - 1:w + 1
            if [nx, ny, nz, nw] != [x, y, z, w]
                push!(result, [nx, ny, nz, nw])
            end
        end
    else
        error("Unssuported number of dimensions $dims")
    end
    result
end

function next(c::Conway; dims=3)::Conway
    result::Conway = Dict()

    # Generate a set of the active cubes and all their possible neighbors
    cubes_to_process = Set(keys(c))
    for cube in keys(c)
        push!(cubes_to_process, neighbors(cube; dims=dims)...)
    end

    # Process the cubes and contribute active ones into the next cycle
    for cube in cubes_to_process
        active = haskey(c, cube)
        active_ns = length([n for n in neighbors(cube; dims=dims) if haskey(c, n)])

        if active && active_ns in [2,3]
            result[cube] = true
        end

        if !active && active_ns == 3
            result[cube] = true
        end
    end

    result
end

function simulate(c::Conway, cycles::Int; dims=3)::Conway
    result = c
    for _ in 1:cycles
        result = next(result; dims=dims)
    end
    result
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    part_one = length(simulate(Conway(input), 6))
    part_two = length(simulate(Conway(input; dims=4), 6; dims=4))
    part_one, part_two
end

function run_tests()
    test_input = """
    .#.
    ..#
    ###
    """
    @test length(simulate(Conway(test_input), 6)) == 112
    @test length(simulate(Conway(test_input; dims=4), 6; dims=4)) == 848
end

run_tests()
@time solve()
