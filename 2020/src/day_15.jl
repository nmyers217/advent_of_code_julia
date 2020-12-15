using Test

"""
I'm not even going to bother optimizing this because this problem was so boring :(
"""
function play(nums::Vector{Int}, max_turn)
    speakings = Dict(n => [turn] for (turn, n) in enumerate(nums))

    prev_spoken = nums[end]
    for turn in length(nums) + 1:max_turn
        s = get!(speakings, prev_spoken, [])
        if length(s) >= 2
            next_spoken = s[end] - s[end - 1]
            push!(get!(speakings, next_spoken, []), turn)
            prev_spoken = next_spoken
        else
            push!(get!(speakings, 0, []), turn)
            prev_spoken = 0
        end
    end

    prev_spoken
end

function solve()
    input = read("2020/res/day_15.txt", String)
    nums = [parse(Int, s) for s in split(strip(input), ",")]
    play(nums, 2020), play(nums, 30_000_000)
end

function run_tests()
    begin
        @test play([0,3,6], 10) == 0
        @test play([1,3,2], 2020) == 1
        @test play([2,1,3], 2020) == 10
        @test play([1,2,3], 2020) == 27
        @test play([2,3,1], 2020) == 78
        @test play([3,2,1], 2020) == 438
        @test play([3,1,2], 2020) == 1836
    end
end

run_tests()
@time solve()