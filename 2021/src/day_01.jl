function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    nums = parse.(Int, split(strip(input), "\n"))

    partone = begin
        result = 0
        for i in 2:length(nums)
            if nums[i] > nums[i-1]; result += 1 end
        end
        result
    end

    parttwo = begin
        subtotals = []
        for i in eachindex(nums)
            total = 0
            for j in i:i+2;
                if j > length(nums) continue end
                total += nums[j]
            end
            push!(subtotals, total)
        end

        result = 0
        for i in 2:length(subtotals)
            if subtotals[i] > subtotals[i-1]; result += 1 end
        end
        result
    end

    partone, parttwo
end

@time @show solve()
