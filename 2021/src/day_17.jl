function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    m = match(r"target area: x=(.+)\.\.(.+), y=(.+)\.\.(.+)", input)
    (left, right, bot, top) = parse.(Int, m.captures)

    iswithin((x, y)) = x in left:right && y in bot:top
    hasexceeded((x, y)) = x > right || y < bot

    testvel(vel) = begin
        loc = (0, 0)
        maxy = loc[2]
        while true
            loc = loc .+ vel
            vel = vel .+ (vel[1] < 0 ? 1 : vel[1] > 0 ? -1 : 0, -1)
            maxy = max(maxy, loc[2])
            if iswithin(loc) return maxy end
            if hasexceeded(loc) return -1 end
        end
    end

    # NOTE: didn't really care about optimizing this, just made it extra large
    velocityspace = [(vx, vy) for vy in -1000:1000, vx in -1000:1000]

    maximum(testvel.(velocityspace)), count(>(-1), testvel.(velocityspace))
end

@time solve()