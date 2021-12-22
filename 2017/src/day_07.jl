using Test

function getgraph(input)
    result = Dict()
    for line in split(strip(input), "\n")
        matches = getfield.(collect(eachmatch(r"(\w+)", line)), [:match])
        (name, weight) = matches[1:2]
        edges = length(matches) > 2 ? matches[3:end] : []
        result[name] = (weight=parse(Int, weight), edges=edges)
    end
    result
end

function getroot(graph)
    first(symdiff(keys(graph), vcat([v.edges for v in values(graph)]...)))
end

function getweight(graph, node)
    node = graph[node]
    if isempty(node.edges) return node.weight end
    node.weight + sum([getweight(graph, e) for e in node.edges])
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    g = getgraph(input)
    root = getroot(g)

    parttwo = begin
        curnode, extraweight = root, 0
        while true
            weights = [getweight(g, e) for e in g[curnode].edges]
            if length(unique(weights)) < 2 break end
            (min, max) = extrema(weights)
            extraweight = max - min
            curnode = g[curnode].edges[findmax(weights)[2]]
        end
        g[curnode].weight - extraweight
    end

    root, parttwo
end

@time @show solve()
