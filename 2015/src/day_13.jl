using Pkg
Pkg.add("DataStructures")
using DataStructures

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    graph = reduce(eachmatch(r"(\w+) .+ (\w+) (\d+) .+ (\w+)", input), init=Dict()) do acc, m
        (from, sign, amount, to) = m.captures
        weight = parse(Int, amount) * (sign == "gain" ? 1 : -1)
        push!(get!(acc, from, Dict()), to => weight)
        acc
    end

    seatall(graph) = begin
        pq = PriorityQueue{Vector{AbstractString}, Int}(Base.Order.Reverse)
        enqueue!(pq, [graph |> keys |> first] => 0)

        bestscore = 0
        while !isempty(pq)
            (arrangement, score) = dequeue_pair!(pq)
            unseated = symdiff(keys(graph), arrangement)

            if isempty(unseated) && score > bestscore
                head, tail = first(arrangement), last(arrangement)
                bestscore = score + graph[head][tail] + graph[tail][head]
            end

            for next in unseated
                cur = last(arrangement)
                nextscore = score + graph[cur][next] + graph[next][cur]
                enqueue!(pq, [arrangement; next] => nextscore)
            end
        end
        bestscore
    end

    partone = seatall(graph)

    parttwo = begin
        for k in keys(graph)
            graph[k]["You"] = 0
        end
        graph["You"] = Dict{Any, Any}(k => 0 for k in keys(graph))
        seatall(graph)
    end

    partone, parttwo
end

@time solve()
