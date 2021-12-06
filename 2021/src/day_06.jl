# NOTE: when in doubt just use a hash map
function tick(ages)
    result = Dict()
    for (k, v) in ages
        if k > 0
            result[k - 1] = get!(result, k - 1, 0) + v
        else
            result[6] = get!(result, 6, 0) + v
            result[8] = get!(result, 8, 0) + v
        end
    end
    result
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    nums = parse.(Int, split(strip(input), ","))

    solve(days) = begin
        result = Dict()

        for num in nums
            n = get!(result, num, 0)
            result[num] = n + 1
        end

        for _ in 1:days
            result = tick(result)
        end

        result |> values |> sum
    end

    solve(80), solve(256)
end

@time solve()