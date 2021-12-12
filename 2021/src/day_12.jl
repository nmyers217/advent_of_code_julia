function getgraph(input)
    result = Dict()
    for line in split(strip(input), "\n")
        (left, right) = split(strip(line), "-")
        push!(get!(result, left, []), right)
        push!(get!(result, right, []), left)
    end
    result
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    graph = getgraph(input)

    partone(cur, dest; seen=[]) = begin
        if cur == dest return 1 end

        result = 0
        for next in graph[cur]
            if next == "start" continue end
            if next in seen continue end
            nextseen = lowercase(next) == next ? [seen; next] : seen
            result += partone(next, dest, seen=nextseen)
        end
        result
    end

    parttwo(cur, dest; seen=Dict()) = begin
        if cur == dest return 1 end

        result = 0
        for next in graph[cur]
            if next == "start" continue end
            if haskey(seen, next) && 2 in values(seen)
                continue
            end

            nextseen = copy(seen)
            if lowercase(next) == next
                get!(nextseen, next, 0)
                nextseen[next] += 1
            end
            result += parttwo(next, dest, seen=nextseen)
        end
        result
    end

    partone("start", "end"), parttwo("start", "end")
end

@time solve()