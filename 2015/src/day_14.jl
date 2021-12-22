function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    reindeer = reduce(eachmatch(r"(\w+) .+ (\d+) .+ (\d+) .+ (\d+) .+", input), init=[]) do acc, m
        push!(acc, tuple([parse(Int, n) for n in m.captures[2:end]]...))
    end

    dist(elapsed, reindeer) = begin
        (speed, traveltime, resttime) = reindeer
        cycletime = traveltime + resttime
        cycles = convert(Int64, floor(elapsed / cycletime))
        (cycles * traveltime + min(traveltime, rem(elapsed, cycletime))) * speed
    end

    partone = maximum(r -> dist(2503, r), reindeer)

    parttwo = begin
        scores = zeros(length(reindeer))
        for e in 1:2503
            distances = [dist(e, r) for r in reindeer] 
            best = maximum(distances)
            for (i, dist) in enumerate(distances)
                if dist == best scores[i] += 1 end
            end
        end
        convert(Int, maximum(scores))
    end

    partone, parttwo
end

@time @show solve()
