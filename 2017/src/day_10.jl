function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    cap = 255

    partone = begin
        nums, pos, skip = collect(0:cap), 1, 0
        for l in [parse(Int, str) for str in split(strip(input), ",")]
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
        nums[1] * nums[2]
    end

    parttwo = begin
        lengths = [[convert(Int, s[1]) for s in split(input, "")]; [17, 31, 73, 47, 23]]
        nums, pos, skip = collect(0:cap), 1, 0
        for r in 1:64, l in lengths
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

    partone, parttwo
end

@time @show solve()
