using Test

function parse_input(str::AbstractString)::Vector{Int}
    [parse(Int, line) for line in split(strip(str), "\n")]
end

function isvalid(nums::Vector{Int}, i::Int, preamble::Int)
    if i > length(nums) || i < preamble
        error("Invalid index $i")
    end

    preamble = nums[i - preamble:i - 1]
    for a in preamble, b in preamble
        if a != b && a + b == nums[i]
            return true
        end
    end

    false
end

function first_invalid(nums::Vector{Int}, preamble::Int=25)
    for i in preamble + 1:length(nums)
        if !isvalid(nums, i, preamble)
            return nums[i]
        end
    end
end

function find_contiguous(nums::Vector{Int}, target::Int)
    for i in 1:length(nums)
        if 1 == length(nums)
            break
        end

        sum = nums[i]
        for j in i + 1:length(nums)
            sum += nums[j]

            if (sum == target)
                block = nums[i:j]
                return minimum(block) + maximum(block)
            end
        end
    end

    error("No contiguous block of numbers added up to target.")
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    nums = parse_input(input)
    part_one = first_invalid(nums)
    part_two = find_contiguous(nums, part_one)
    part_one, part_two
end

function run_tests()
    test_input = [ 35, 20, 15, 25, 47, 40, 62, 55, 65, 95, 102, 117, 150, 182, 127, 219, 299, 277, 309, 576 ]
    @test first_invalid(test_input, 5) == 127
    @test find_contiguous(test_input, 127) == 62
end

run_tests()
@time solve()
