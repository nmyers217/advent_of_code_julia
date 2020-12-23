"""
Find how many possible valid subsets of ratings would fulfill the power requirements
using a dyanmic programming approach
"""
function valid_sets(ratings::Vector{Int}, memo::Any=Dict())
    if haskey(memo, ratings)
        return memo[ratings]
    end

    if length(ratings) < 3
        1
    else
        # Include all possible values
        result = valid_sets(ratings[1:end - 1], memo)

        # Exlcude all possible values
        i = length(ratings) - 1
        while i > 1 && ratings[end] - ratings[i - 1] <= 3
            i -= 1
        end
        if i < length(ratings) - 1
            result += valid_sets(ratings[1:i], memo)
        end

        # Add possible combinations if there are more than 1 branch
        if i < length(ratings) - 2
            result += valid_sets([ratings[1:i]; ratings[i + 1]], memo)
        end

        # Memoize completed subproblems
        memo[ratings] = result
    end
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    ratings = begin
        list = sort([parse(Int, line) for line in split(strip(input), "\n")])
        [0; list; last(list) + 3]
    end
    diffs = [b - a for (a, b) in zip(ratings[1:end - 1], ratings[2:end])]
    part_one = count(==(1), diffs) * count(==(3), diffs)
    part_two = valid_sets(ratings)
    part_one, part_two
end

@time solve()
