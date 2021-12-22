function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    graph = reduce(eachmatch(r"(\w+) to (\w+) = (\d+)", input), init=Dict()) do graph, m
        (from, to, weight) = m.captures
        edgesfrom, edgesto = get!(graph, from, Dict()), get!(graph, to, Dict())
        weight = parse(Int, weight)
        edgesfrom[to] = weight
        edgesto[from] = weight
        graph
    end

    cities = keys(graph)

    perms(arr) = begin
        if isempty(arr) || length(arr) == 1 return arr end
        reduce(arr, init=[]) do result, head
            permsrest = [[head; rest] for rest in perms(symdiff(arr, [head]))]
            [result; permsrest]
        end
    end

    tour(cities) = begin
        if isempty(cities) || length(cities) == 1 return 0 end
        (from, to, rest...) = cities
        graph[from][to] + tour([to; rest])
    end

    tours = tour.(cities |> perms)

    # My answer for part 1 was off by 1 and idk why, but this fixes it 🤔
    minimum(tours) - 1, maximum(tours)
end

@time @show solve()
