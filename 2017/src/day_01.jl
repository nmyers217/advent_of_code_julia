function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    nums = [parse(Int, n) for n in split(strip(input), "")]
    halflength = convert(Int, length(nums) / 2)
    partone, parttwo = 0, 0
    for i in eachindex(nums)
        if nums[i] === nums[mod1(i + 1, length(nums))] partone += nums[i] end
        if nums[i] === nums[mod1(i + halflength, length(nums))] parttwo += nums[i] end
    end
    partone, parttwo
end

@time solve()
