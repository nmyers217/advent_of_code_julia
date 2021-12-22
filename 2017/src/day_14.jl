# NOTE: This is copied from day 10
function hash(str)
    lengths = [[convert(Int, s[1]) for s in split(str, "")]; [17, 31, 73, 47, 23]]
    nums, pos, skip = collect(0:255), 1, 0
    for _ in 1:64, l in lengths
        if l > 0
            # View the nums starting from pos
            nums = circshift(nums, -(pos - 1))
            # Reverse the span for length l
            nums = [reverse(nums[1:l]); nums[l+1:end]]
            # View the list from the beginning again
            nums = circshift(nums, pos - 1)
        end
        pos = mod1(pos + l + skip, length(nums))
        skip += 1
    end
    dense = [xor(col...) for col in eachcol(reshape(nums, (16, 16)))]
    reduce(zip(dense, collect(15:-1:0)), init=UInt128(0)) do hash, (n, bytes)
        hash |= UInt128(n) << (bytes * 8)
    end
end

# This is 🤮 but i wanted to be 1337 and do this with actual bit manipulation and masking
function tobinary(hash)
    result = []
    for char in 31:-1:0
        mask = UInt128(0xf) << (31 * 4)
        bits = bitstring(Int8((mask & (hash << ((31 - char) * 4))) >> (31 * 4)))[5:end]
        push!(result, bits)
    end
    join(result)
end

function dfs(grid, start, seen)
    result, stack = copy(seen), [start]
    while !isempty(stack)
        (row, col) = pop!(stack)
        if row < 1 || row > 128 || col < 1 || col > 128; continue end
        if grid[row][col] == '0' || (row, col) in result; continue end
        push!(result, (row, col))
        for dir in [(-1, 0), (1, 0), (0, -1), (0, 1)]
            push!(stack, (row, col) .+ dir)
        end
    end
    result
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    grid = [hash("$input-$n") |> tobinary for n in 0:127]

    partone = sum(count(==('1'), line) for line in grid)

    parttwo = begin
        islands, seen = 0, Set()
        for row in 1:128, col in 1:128
            if grid[row][col] == '0' || (row, col) in seen; continue end
            visited = dfs(grid, (row, col), seen)
            if length(visited) > 0; islands += 1 end
            union!(seen, visited)
        end
        islands
    end

    partone, parttwo
end

@time @show solve()
