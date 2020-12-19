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

function isvalid(msg::AbstractString, g::Graph, rule::Int=0)
    # A recursive helper function
    rh(rule, i=1) = begin
        if i > length(msg)
            # The message was too short to match
            return true, 0
        end

        node = g[rule]

        if !isnothing(node.val)
            # println("i = $i: $(msg[i]) == $(node.val)")
            match = msg[i] == node.val
            return match, match ? 1 : 0
        end

        for child in [node.left, node.right]
            if isnothing(child)
                continue
            end

            is_match = true
            Δi = 0
            for id in child
                next_i = i + Δi

                # if next_i > length(msg)
                #     return is_match, is_match ? i : 0
                # end

                (m, Δ) = rh(id, next_i)
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

    test_input = """
    42: 9 14 | 10 1
    9: 14 27 | 1 26
    10: 23 14 | 28 1
    1: "a"
    11: 42 31
    5: 1 14 | 15 1
    19: 14 1 | 14 14
    12: 24 14 | 19 1
    16: 15 1 | 14 14
    31: 14 17 | 1 13
    6: 14 14 | 1 14
    2: 1 24 | 14 4
    0: 8 11
    13: 14 3 | 1 12
    15: 1 | 14
    17: 14 2 | 1 7
    23: 25 1 | 22 14
    28: 16 1
    4: 1 1
    20: 14 14 | 1 15
    3: 5 14 | 16 1
    27: 1 6 | 14 18
    14: "b"
    21: 14 1 | 1 14
    25: 1 1 | 1 14
    22: 14 14
    8: 42
    26: 14 22 | 1 20
    18: 15 15
    7: 14 5 | 1 21
    24: 14 1

    abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
    bbabbbbaabaabba
    babbbbaabbbbbabbbbbbaabaaabaaa
    aaabbbbbbaaaabaababaabababbabaaabbababababaaa
    bbbbbbbaaaabbbbaaabbabaaa
    bbbababbbbaaaaaaaabbababaaababaabab
    ababaaaaaabaaab
    ababaaaaabbbaba
    baabbaaaabbaaaababbaababb
    abbbbabbbbaaaababbbbbbaaaababb
    aaaaabbaabaaaaababaa
    aaaabbaaaabbaaa
    aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
    babaaabbbaaabaababbaabababaaab
    aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba
    """

    (rules_str, msgs_str) = split(strip(input), "\n\n")
    msgs = split(strip(msgs_str), "\n")
    rules = Graph(rules_str)

    part_one = count(m -> isvalid(m, rules), msgs)

    part_two = begin
        rules[8] = Node(nothing, rules[8].left, [42, 8])
        rules[11] = Node(nothing, rules[11].left, [42, 11, 31])
        count(m -> isvalid(m, rules), msgs)
    end

    right_answer = [
        "bbabbbbaabaabba",
        "babbbbaabbbbbabbbbbbaabaaabaaa",
        "aaabbbbbbaaaabaababaabababbabaaabbababababaaa",
        "bbbbbbbaaaabbbbaaabbabaaa",
        "bbbababbbbaaaaaaaabbababaaababaabab",
        "ababaaaaaabaaab",
        "ababaaaaabbbaba",
        "baabbaaaabbaaaababbaababb",
        "abbbbabbbbaaaababbbbbbaaaababb",
        "aaaaabbaabaaaaababaa",
        "aaaabbaabbaaaaaaabbbabbbaaabbaabaaa",
        "aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba"
    ]

    wtf = "aaaabbaaaabbaaa"

    symdiff(part_two, right_answer)

    # isvalid(wtf, rules)
    part_one, part_two
end

@time solve()