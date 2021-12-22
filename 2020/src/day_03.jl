using Test

parse_rows(input) = [split(row, "") for row in split(strip(input), "\n")]

function tree_count(rows, slope::Tuple{Int,Int})
    (run, rise) = slope
    (x, y) = (1, 1)
    (open, trees) = (0, 0)

    while true
        x = mod1(x + run, length(first(rows)))
        y += rise

        if y > size(rows, 1)
            break
        end

        if rows[y][x] == "."
            open += 1
        else
            trees += 1
        end
    end

    trees
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    rows = parse_rows(input)

    part_one = tree_count(rows, (3, 1))

    slopes = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]
    part_two = prod([tree_count(rows, slope) for slope in slopes])

    (part_one, part_two)
end

function run_tests()
    test_input = """
    ..##.......
    #...#...#..
    .#....#..#.
    ..#.#...#.#
    .#...##..#.
    ..#.##.....
    .#.#.#....#
    .#........#
    #.##...#...
    #...##....#
    .#..#...#.#
    """
    @test tree_count(parse_rows(test_input), (1, 1)) == 2
    @test tree_count(parse_rows(test_input), (3, 1)) == 7
    @test tree_count(parse_rows(test_input), (5, 1)) == 3
    @test tree_count(parse_rows(test_input), (7, 1)) == 4
    @test tree_count(parse_rows(test_input), (1, 2)) == 2
end

run_tests()
@time @show solve()
