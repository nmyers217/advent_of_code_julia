function solve()
    wires = map(collect(eachline("res/day_03.txt"))) do line
        map(split(strip(line), ",")) do move
            dir, mag = move[1], move[2:end]

            # Parse the direction into a 2d unit vector
            dir = if dir == 'R'
                (1, 0)
            elseif dir == 'L'
                (-1, 0)
            elseif dir == 'U'
                (0, -1)
            elseif dir == 'D'
                (0, 1)
            else
                error("Invalid direction $dir")
            end

            # Parse the scalar magnitured of the direction vector
            mag = parse(Int, mag)

            dir, mag
        end
    end

    (wire_a, wire_b) = map(wires) do wire
        # A set of all the points the wire's path took
        points_visited = Set()
        # A lookup that maps each point visited to the # of steps taken
        step_lookup = Dict()

        pos = (0, 0)
        steps = 0

        for (dir, mag) in wire
            for n in 0:(mag - 1)
                pos = map(+, pos, dir)
                steps += 1
                push!(points_visited, pos)
                step_lookup[pos] = steps
            end
        end

        points_visited, step_lookup
    end

    points_visited_a, step_lookup_a = wire_a
    points_visited_b, step_lookup_b = wire_b

    intersections = intersect(points_visited_a, points_visited_b)

    manhattan((x, y)) = abs(x) + abs(y)

    steps_to_intersections = map(collect(intersections)) do pos
        step_lookup_a[pos] + step_lookup_b[pos]
    end

    part_one = min(map(manhattan, collect(intersections))...)
    part_two = min(steps_to_intersections...)
    part_one, part_two
end

solve()
