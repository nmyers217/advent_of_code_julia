const Direction = Tuple{Char,Int}
const Directions = Vector{Direction}

mutable struct Ship
    pos::Vector{Int}
    dir::Vector{Int}
    waypoint::Vector{Int}
    Ship() = new([0, 0], [1, 0], [10, -1])
end

function parse_input(input::AbstractString)::Directions
    lines = split(strip(input), "\n")
    [(l[1], parse(Int, l[2:end])) for l in lines]
end

function move!(ship::Ship, direction::Direction; waypoint=false)
    (t, amt) = direction

    if t in ['N', 'S', 'E', 'W']
        dirs = Dict('N' => [0, -1], 'S' => [0, 1], 'E' => [1, 0], 'W' => [-1, 0])
        v = dirs[t] * amt

        if waypoint 
            ship.waypoint += v
        else
            ship.pos += v
        end
    elseif t in ['L', 'R']
        rot((x, y)) = begin
            if t == 'L'
                [y, -x]
            else
                [-y, x]
            end
        end

        for _ in 1:convert(Int, amt / 90)
            if waypoint
                ship.waypoint = rot(ship.waypoint)
            else
                ship.dir = rot(ship.dir)
            end
        end
    elseif t == 'F'
        ship.pos += (waypoint ? ship.waypoint : ship.dir) * amt
    else
        error("Invalid direction type $t")
    end
end

function travel!(ship::Ship, directions::Directions; waypoint=false)
    for dir in directions
        move!(ship, dir; waypoint=waypoint)
    end
end

function solve()
    input = read("2020/res/day_12.txt", String)
    directions = parse_input(input)
    part_one = begin
        ship = Ship()
        travel!(ship, directions)
        sum(abs.(ship.pos))
    end
    part_two = begin
        ship = Ship()
        travel!(ship, directions; waypoint=true)
        sum(abs.(ship.pos))
    end
    part_one, part_two
end

@time solve()