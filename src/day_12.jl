using Test

mutable struct Moon
    pos::Vector{Int}
    vel::Vector{Int}
    Moon(pos) = new(pos, [0, 0, 0])
    Moon(pos, vel) = new(pos, vel)
end

function parse_moons(input::String)::Array{Moon,1}
    lines = split(strip(input), "\n")
    map(lines) do line
        m = match(r"<x=(\S+), y=(\S+), z=(\S+)>", line)
        pos = [parse(Int, s) for s in m.captures]
        Moon(pos)
    end
end

function tick(moons::Array{Moon,1})::Array{Moon,1}
    result = []

    # Calculate the velocity for each moon
    for moon in moons
        vel = copy(moon.vel)
        for axis in 1:length(moon.pos)
            for other_moon in moons
                if moon == other_moon
                    continue
                end
                vel[axis] += cmp(other_moon.pos[axis], moon.pos[axis])
            end
        end
        push!(result, Moon(copy(moon.pos), vel))
    end

    # Advance the positions
    for moon in result
        moon.pos += moon.vel
    end

    result
end

function system_energy(moons::Array{Moon,1})::Int
    sum_abs(v) = sum(map(abs, v))
    sum(map(moon -> sum_abs(moon.pos) * sum_abs(moon.vel), moons))
end

function solve()
    input = read("res/day_12.txt", String)

    moons = parse_moons(input)
    for _ in 1:1000
        moons = tick(moons)
    end
    part_one = system_energy(moons)
    part_one
end

function run_tests()
    input = """
    <x=-1, y=0, z=2>
    <x=2, y=-10, z=-7>
    <x=4, y=-8, z=8>
    <x=3, y=5, z=-1>
    """
    moons = parse_moons(input)
    for _ in 1:10
        moons = tick(moons)
    end
    @test system_energy(moons) == 179
end

solve()
