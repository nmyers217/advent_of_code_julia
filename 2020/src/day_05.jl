using Test

parse_input(input::String) = split(strip(input), "\n")

function seat_id(boarding_pass::AbstractString)
    bsearch(list, bounds, chars) = begin
        (lower, upper) = bounds
        for c in list
            if c == chars[1]
                upper = floor(Int, (lower + upper) / 2)
            elseif c == chars[2]
                lower = ceil(Int, (lower + upper) / 2)
            else
                error("Invalid char $c")
            end
        end
        lower
    end

    row = bsearch(boarding_pass[1:7], (0, 127), ('F', 'B'))
    col = bsearch(boarding_pass[8:10], (0, 7), ('L', 'R'))

    row * 8 + col
end

function solve()
    input = read("2020/res/day_05.txt", String)
    all_ids = sort([seat_id(pass) for pass in parse_input(input)])

    part_one = maximum(all_ids)

    part_two = -Inf
    for i in 2:length(all_ids)
        if all_ids[i] - all_ids[i - 1] > 1
            part_two = all_ids[i] - 1
        end
    end

    (part_one, part_two)
end

function run_tests()
    @test seat_id("FBFBBFFRLR") == 357
    @test seat_id("BFFFBBFRRR") == 567
    @test seat_id("FFFBBBFRRR") == 119
    @test seat_id("BBFFBBFRLL") == 820
end

run_tests()
solve()