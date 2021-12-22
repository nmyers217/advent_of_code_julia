function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    isintersection(cube1, cube2) = all(1:3) do d
        (cube1[d][1] <= cube2[d][1] <= cube1[d][2]) || (cube2[d][1] <= cube1[d][1] <= cube2[d][2])
    end

    buildcubeset(isreboot) = begin
        cubes = []
        for m in eachmatch(r"(\w+) x=(.+)\.\.(.+),y=(.+)\.\.(.+),z=(.+)\.\.(.+)", input)
            (state, rest...) = m.captures
            (minx, maxx, miny, maxy, minz, maxz) = parse.(Int, rest)
            cube = [(minx, maxx), (miny, maxy), (minz, maxz)]

            if isreboot && (any(<(-50), [maxx, maxy, maxz]) || any(>(50), [minx, miny, minz]))
                continue
            end

            intersections = filter(cubes) do (_, cube2...) isintersection(cube, cube2) end

            for (ison, cube2...) in intersections
                negatedcube = map(1:3) do d
                    (max(cube[d][1], cube2[d][1]), min(cube[d][2], cube2[d][2]))
                end
                push!(cubes, [ison * -1; negatedcube])
            end

            if state == "on" push!(cubes, [1, cube...]) end
        end
        cubes
    end

    partone = reduce(buildcubeset(true), init=0) do acc, (ison, cube...)
        acc + ison * prod([maxd - mind + 1 for (mind, maxd) in cube])
    end

    parttwo = reduce(buildcubeset(false), init=0) do acc, (ison, cube...)
        acc + ison * prod([maxd - mind + 1 for (mind, maxd) in cube])
    end

    partone, parttwo
end

@time solve()