function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    blocks = [parse(Int, str) for str in split(strip(input), "\t")]

    distribute() = begin
        redist, largest_i = findmax(blocks)
        blocks[largest_i] = 0
        cur_i = largest_i + 1

        while redist > 0
            cur_i = mod1(cur_i, length(blocks))
            blocks[cur_i] += 1
            redist -= 1
            cur_i += 1
        end
    end

    cycles, seen, seenon = 0, Set([copy(blocks)]), Dict(copy(blocks) => 0)
    while true
        distribute()
        cycles += 1
        if blocks in seen break end
        push!(seen, copy(blocks))
        seenon[copy(blocks)] = cycles
    end

    cycles, cycles - seenon[blocks]
end

@time @show solve()
