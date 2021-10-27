function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    graph = reduce(eachmatch(r"(.+) -> (.+)", input), init=Dict()) do graph, m
        (left, node) = m.captures
        graph[node] = map(split(left, " ")) do word
            isnothing(match(r"[1-9]+", word)) ? word : parse(UInt16, word)
        end
        graph
    end

    signal(node; memo=Dict{AbstractString, UInt16}()) = begin
        if haskey(memo, node) return memo[node] end
        if typeof(node) <: Number return UInt16(node) end

        val = get(graph, node, [UInt16(0)])

        memo[node] = if length(val) == 1
            typeof(val[1]) <: Number ? val[1] : signal(val[1], memo=memo)
        elseif "NOT" in val
            ~signal(val[2], memo=memo)
        elseif "AND" in val
            signal(val[1], memo=memo) & signal(val[3], memo=memo)
        elseif "OR" in val
            signal(val[1], memo=memo) | signal(val[3], memo=memo)
        elseif "LSHIFT" in val
            signal(val[1], memo=memo) << val[3]
        elseif "RSHIFT" in val
            signal(val[1], memo=memo) >> val[3]
        else
            error("Unsupported: $val")
        end

        return memo[node]
    end

    partone = signal("a") |> Int

    parttwo = begin
        signal("a", memo=Dict("b" => signal("a"))) |> Int
    end

    partone, parttwo
end

@time solve()
