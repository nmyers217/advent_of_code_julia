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

function axis_equal(moons_a::Array{Moon,1}, moons_b::Array{Moon,1}, axis::Int)
    for i in eachindex(moons_a)
        (a, b) = (moons_a[i], moons_b[i])
        if a.pos[axis] != b.pos[axis] || a.vel[axis] != b.vel[axis]
            return false
        end
    end
    true
end

function solve()
    input = read("res/day_12.txt", String)

    part_one = begin
        moons = parse_moons(input)
        for _ in 1:1000
            moons = tick(moons)
        end
        system_energy(moons)
    end

    part_two = begin
        # NOTE: I used UnicodePlots  to mess around with some stuff
        # to get a feel for how the moons were cycling around
        # before i realized the way to go was to find how long each
        # axis of the system takes to realign
        #
        # x1 = map(m -> m[1].pos[1], moons)
        # x2 = map(m -> m[2].pos[1], moons)
        # x3 = map(m -> m[3].pos[1], moons)
        # x4 = map(m -> m[4].pos[1], moons)
        # xplot = lineplot(0:ticks, x1, color=:green, name="x1", xlabel="tick", ylabel="value", width=60)
        # lineplot!(xplot, 0:ticks, x2, color=:blue, name="x2")
        # lineplot!(xplot, 0:ticks, x3, color=:red, name="x3")
        # lineplot!(xplot, 0:ticks, x4, color=:yellow, name="x4")

        moons = parse_moons(input)
        initial_moons = deepcopy(moons)
        axis_cycles = [0, 0, 0]
        t = 1
        while any(==(0), axis_cycles)
            moons = tick(moons)

            for i in eachindex(axis_cycles)
                if axis_cycles[i] == 0 && axis_equal(moons, initial_moons, i)
                    axis_cycles[i] = t
                end
            end
            
            t += 1
        end

        # The least common multiple of the 3 axes' cycles is the answer
        lcm(axis_cycles)
    end

    (part_one, part_two)
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
