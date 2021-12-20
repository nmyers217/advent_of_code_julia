function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    (algo, image) = begin
        paragraphs = split(strip(input), "\n\n")
        algo = join(split(paragraphs[1], "\n"))
        image = Dict()
        for (y, line) in enumerate(split(paragraphs[2], "\n"))
            for (x, c) in enumerate(line)
                image[(x, y)] = c[1]
            end
        end
        algo, image
    end

    directions = [
        (-1, -1), (0, -1), (1, -1),
        (-1,  0), (0,  0), (1,  0),
        (-1,  1), (0,  1), (1,  1),
    ]

    expand(image, n) = begin
        result = copy(image)

        points = keys(image)
        (miny, maxy) = extrema([p[2] for p in points])
        (minx, maxx) = extrema([p[1] for p in points])

        for y in miny-2:maxy+2, x in minx-2:maxx+2
            point = (x, y)
            default = ['.', '#'][mod1(n, 2)]
            pixels = map(directions) do dir
                get(image, point .+ dir, default) == '#' ? '1' : '0'
            end
            i = parse(Int, "0b$(join(pixels))") + 1

            result[point] = algo[i]
        end

        result
    end

    partone = begin
        output = image
        for n in 1:2 output = expand(output, n) end
        count(==('#'), values(output))
    end

    parttwo = begin
        output = image
        for n in 1:50 output = expand(output, n) end
        count(==('#'), values(output))
    end

    partone, parttwo
end

@time solve()