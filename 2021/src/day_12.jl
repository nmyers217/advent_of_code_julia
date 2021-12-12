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

    partone = begin
        numpaths(cur, dest; seen=[]) = begin
            if cur == dest return 1 end

            result = 0
            for next in graph[cur]
                if next == "start" continue end
                if next in seen continue end
                nextseen = lowercase(next) == next ? [seen; next] : seen
                result += numpaths(next, dest, seen=nextseen)
            end
            result
        end

        numpaths("start", "end")
    end

    parttwo = begin
        numpathsnew(cur, dest; seen=Dict()) = begin
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
                result += numpathsnew(next, dest, seen=nextseen)
            end
            result
        end

        numpathsnew("start", "end")
    end

    partone, parttwo
end

@time solve()