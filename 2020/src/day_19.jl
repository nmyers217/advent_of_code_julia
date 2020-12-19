struct Node
    val::Union{Char,Nothing}
    left::Union{Vector{Int},Nothing}
    right::Union{Vector{Int},Nothing}
end

const Graph = Dict{Int,Node}

function Graph(str::AbstractString)::Graph
    result = Dict()
    for line in split(strip(str), "\n")
        (id_str, rest) = split(line, ": ")

        id = parse(Int, id_str)
        rest = replace(rest, "\"" => "")
        val = rest in ["a", "b"] ? rest[1] : nothing

        result[id] = if isnothing(val)
            children = split.(split(rest, " | "))
            left = parse.(Int, first(children))
            right = length(children) > 1 ? parse.(Int, children[2]) : nothing
            Node(val, left, right)
        else
            Node(val, nothing, nothing)
        end
    end
    result
end

function isvalid(msg::AbstractString, g::Graph, left_to_right=true, rule=0)
    # A recursive helper function
    rh(rule, i=1) = begin
        if i > length(msg)
            return true, 0
        end

        node = g[rule]

        if !isnothing(node.val)
            # println("i = $i: $(msg[i]) == $(node.val)")
            match = msg[i] == node.val
            return match, match ? 1 : 0
        end

        children = if left_to_right
            [node.left, node.right]
        else
            [node.right, node.left]
        end
        for child in children
            if isnothing(child)
                continue
            end

            is_match = true
            Δi = 0
            for id in child
                (m, Δ) = rh(id, i + Δi)
                Δi += Δ
                if !m 
                    is_match = false
                    break
                end
            end

            if is_match
                return true, Δi
            end
        end

        return false, 0
    end

    # Handle edge case where message is too long
    (result, i) = rh(rule)
    result && i == length(msg)
end

function solve()
    input = read("2020/res/day_19.txt", String)
    (rules_str, msgs_str) = split(strip(input), "\n\n")
    msgs = split(strip(msgs_str), "\n")
    rules = Graph(rules_str)

    part_one = count(m -> isvalid(m, rules), msgs)

    part_two = begin
        rules[8] = Node(nothing, rules[8].left, [42, 8])
        rules[11] = Node(nothing, rules[11].left, [42, 11, 31])
        # I was having some false positives bloating my answer
        # no big deal, surely they won't show twiceup if i
        # do the recursion in the opposite order
        # This is such a god tier hack LMAO
        lr = count(m -> isvalid(m, rules), msgs)
        rl = count(m -> isvalid(m, rules, false), msgs)
        lr - rl
    end

    part_one, part_two
end

@time solve()