function getmatrix(input)
    lines = split(strip(input), "\n")
    result = fill(0, (lines |> length, lines |> first |> length))
    for (y, line) in enumerate(lines)
        for (x, col) in enumerate(line)
            result[y, x] = parse(Int, col)
        end
    end
    result
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    dirs = [
        (-1, -1), (-1, 0), (-1, 1),
        ( 0, -1),          ( 0, 1),
        ( 1, -1), ( 1, 0), ( 1, 1),
    ]

    energies = getmatrix(input)
    full = []
    totalfull, i = 0, 0
    partone, parttwo = 0, 0

    inc((y, x)) = begin
        energies[y, x] += 1
        if energies[y, x] == 10
            totalfull += 1
            energies[y, x] = 0
            push!(full, (y, x))
        end
    end

    while true
        totalfullold = totalfull

        for y in 1:size(energies, 1), x in 1:size(energies, 2)
            inc((y, x))
        end

        while !isempty(full)
            (y, x) = popfirst!(full)

            for d in dirs
                (ny, nx) = (y, x) .+ d

                if ny < 1 || ny > size(energies, 1)|| nx < 1 || nx > size(energies, 2)
                    continue
                end

                if energies[ny, nx] != 0
                    inc((ny, nx))
                end
            end
        end

        i += 1

        if i == 100
            partone = totalfull
        end

        if totalfull - totalfullold == length(energies)
            parttwo = i
            break
        end
    end

    partone, parttwo
end

@time solve()