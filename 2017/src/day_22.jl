function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    lines = split(strip(input), "\n")
    center = tuple([convert(Int, (n - 1) / 2) for n in (length(first(lines)), length(lines))]...) .+ 1

    getinfected() = begin
        reduce(eachindex(lines), init=Set()) do acc, y
            chars = [str[1] for str in split(strip(lines[y]), "")]
            for (x, c) in enumerate(chars)
                if c == '#'; push!(acc, (x, y)) end
            end
            acc
        end
    end

    left((x, y)) = (y, -x)
    right((x, y)) = (-y, x)
    rev(dir) = dir .* -1

    partone = begin
        infected, pos, dir, numinfected = getinfected(), center, (0, -1), 0
        for _ in 1:10_000
            if pos ∉ infected
                dir = left(dir)
                push!(infected, pos)
                numinfected += 1
            else
                dir = right(dir)
                delete!(infected, pos)
            end

            pos = pos .+ dir
        end
        numinfected
    end

    parttwo = begin
        infected, weakened, flagged = getinfected(), Set(), Set()
        pos, dir, numinfected = center, (0, -1), 0
        for _ in 1:10_000_000
            if pos in infected
                dir = right(dir)
                delete!(infected, pos)
                push!(flagged, pos)
            elseif pos in weakened
                delete!(weakened, pos)
                push!(infected, pos)
                numinfected += 1
            elseif pos in flagged
                dir = rev(dir)
                delete!(flagged, pos)
            else
                dir = left(dir)
                push!(weakened, pos)
            end

            pos = pos .+ dir
        end
        numinfected
    end

    partone, parttwo
end

@time solve()
