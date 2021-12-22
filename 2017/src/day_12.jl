function getgraph(input)
    result = Dict()
    for line in split(strip(input), "\n")
        (left, right) = split(line, " <-> ")
        result[parse(Int, left)] = [parse(Int, s) for s in split(right, ",")]
    end
    result
end

function dfs(graph, start)
    seen, stack = Set(start), [start]
    while !isempty(stack)
        cur = pop!(stack)
        for edge in graph[cur]
            if edge in seen continue end
            push!(stack, edge)
            push!(seen, edge)
        end
    end
    seen
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    g = getgraph(input)

    partone = length(dfs(g, 0))

    parttwo = begin
        islands, seen = 0, Set()
        for node in keys(g)
            if node in seen continue end
            island = dfs(g, node)
            islands += 1
            union!(seen, island)
        end
        islands
    end

    partone, parttwo
end

@time @show solve()
