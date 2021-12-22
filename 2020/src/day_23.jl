function play!(list::Vector{Int}, moves=100)
    move = 1
    cur = list[1]
    min, max = extrema(list)
    circle = Dict(
        list[i] => list[mod1(i + 1, length(list))] for i in 1:length(list)
    )

    for _ in 1:moves
        pick_start = circle[cur]
        pick_end = circle[circle[circle[pick_start]]]
        picked = [pick_start, circle[pick_start], circle[circle[pick_start]]]
        dest = begin
            res = cur - 1
            while res in picked || !(min <= res <= max)
                res -= 1
                if res < min
                    res = max
                end
            end
            res
        end

        # Remove the picked items from the circle
        circle[cur] = pick_end
        # Place them after the dest
        temp = circle[dest]
        circle[dest] = pick_start
        circle[picked[end]] = temp

        cur = circle[cur]
        move += 1
    end

    result = []
    node = circle[min]
    while node != min
        push!(result, node)
        node = circle[node]
    end
    result
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    part_one = join(play!(parse.(Int, split(strip(input), ""))))
    part_two = begin
        l = parse.(Int, split(strip(input), ""))
        l = [l; maximum(l) + 1:1_000_000]
        prod(play!(l, 10_000_000)[1:2])
    end
    part_one, part_two
end

@time @show solve()
