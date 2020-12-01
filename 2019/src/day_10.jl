using LinearAlgebra
using Test

# A normal 2d vector to be used with our grid
const Vec = Array{Int,1}
# A 2d vector that represents a unit direction
const UnitDir = Array{Float64,1}

function find_asteroids(map::String)::Set{Vec}
    result = Set()
    for (y, line) in enumerate(split(strip(map), "\n"))
        for (x, c) in enumerate(split(line, ""))
            if c != "."
                push!(result, [x - 1, y - 1])
            end
        end
    end
    result
end

# Floats this close to eachother can be considered equivalent
# this is needed to get around floating point imprecision
const EPSILON = 0.0001;
function dir_equal(a::UnitDir, b::UnitDir)
    (x_delta, y_delta) = b - a
    abs(x_delta) < EPSILON && abs(y_delta) < EPSILON
end

function find_directions(pos::Vec, asteroids::Set{Vec})::Dict{UnitDir,Array{Vec,1}}
    mag_squared(v) = sum([x^2 for x in v])

    result = Dict{UnitDir,Array{Vec,1}}()
    for other in asteroids
        if pos == other
            continue
        end

        # Get a vector from pos to other
        dir = other - pos
        # Normalize it to get the unit vector
        dir_unit::UnitDir = normalize(dir)

        # We have to check the keys this way to get around floating point imprecision
        match_found = false
        for (key, val) in result
            if dir_equal(key, dir_unit)
                # There are already other asteroids on this direction, so add this one
                # to the list and sort it from closest to farthest (magnitude of direction)
                match_found = true
                push!(val, other)
                sort!(val, by=other -> mag_squared(other - pos))
                break
            end
        end

        if !match_found
            # Start a new list of asteroids on this direction
            result[dir_unit] = [other]
        end
    end
    result
end

function best_pos(asteroids::Set{Vec})::Tuple{Vec,Int}
    final_pos = (Inf, Inf)
    most_visible = -Inf
    for pos in asteroids
        directions = find_directions(pos, asteroids)
        amt_visible = length(keys(directions))  
        if amt_visible > most_visible
            final_pos = pos
            most_visible = amt_visible
        end
    end
    final_pos, most_visible
end

function laser(asteroids::Set{Vec}, laser_pos::Vec)::Array{Vec,1}
    angle_between(a::Array{Float64,1}, b::Array{Float64,1}) = begin
        # Find the shortest angle required to turn a so that it becomes b
        angle = acos(dot(a, b) / (norm(a) * norm(b)))

        angle_is_negative = b[1] < 0

        if angle_is_negative
            # Negative x coords are more than π radians
            # that means we want the long way to b, not the short way
            (2 * π) - angle
        else
            angle
        end
    end

    directions = find_directions(laser_pos, asteroids)
    start_dir::UnitDir = [0.0,-1.0]
    sorted_keys = sort(collect(keys(directions)), by=dir -> angle_between(start_dir, dir))

    result = []
    i = 1
    num_destroyed = 0
    while num_destroyed < length(asteroids) - 1
        dir = sorted_keys[i]
        targets = directions[dir]

        if length(targets) > 0
            push!(result, popfirst!(targets))
            num_destroyed += 1
        end

        i += 1
        if i > length(sorted_keys)
            # Circle back to the beginning of the list
            i = mod1(i, length(sorted_keys))
        end
    end
    result
end

function solve()
    input = read("2019/res/day_10.txt", String)

    asteroids = find_asteroids(input)
   
    pos, amt = best_pos(asteroids)
    part_one = amt

    (x, y) = laser(asteroids, pos)[200]
    part_two = x * 100 + y

    part_one, part_two
end

function run_tests()
    @testset "find_directions" begin
        input = """
        #.........
        ...A......
        ...B..a...
        .EDCG....a
        ..F.c.b...
        .....c....
        ..efd.c.gb
        .......c..
        ....f...c.
        ...e..d..c
        """
        asteroids = find_asteroids(input)
        directions = find_directions([0, 0], asteroids)
        for (key, val) in directions
            for pos in val
                @test pos in asteroids
            end
        end
        @test length(keys(directions)) == 7
        @test maximum([length(x) for x in values(directions)]) == 7
    end

    input = """
    .#..##.###...#######
    ##.############..##.
    .#.######.########.#
    .###.#######.####.#.
    #####.##.#.##.###.##
    ..#####..#.#########
    ####################
    #.####....###.#.#.##
    ##.#################
    #####.##.###..####..
    ..######..##.#######
    ####.##.####...##..#
    .#####..#.######.###
    ##...#.##########...
    #.##########.#######
    .####.#.###.###.#.##
    ....##.##.###..#####
    .#.#.###########.###
    #.#.#.#####.####.###
    ###.##.####.##.#..##
    """

    @testset "best_pos" begin
        pos, amt = best_pos(find_asteroids(input))
        @test (pos, amt) == ([11,13], 210)
    end

    @testset "laser" begin
        asteroids = find_asteroids(input)
        destroyed = laser(asteroids, [11,13])
        @test destroyed[1] == [11,12]
        @test destroyed[2] == [12,1]
        @test destroyed[3] == [12,2]
        @test destroyed[10] == [12,8]
        @test destroyed[20] == [16,0]
        @test destroyed[50] == [16,9]
        @test destroyed[100] == [10,16]
        @test destroyed[199] == [9,6]
        @test destroyed[200] == [8,2]
        @test destroyed[201] == [10,9]
        @test destroyed[299] == [11,1]
    end
end

solve()
