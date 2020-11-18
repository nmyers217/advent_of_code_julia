using Test

const Graph = Dict{String,String}

function parse_graph(str)::Graph
    result = Dict{String,String}()
    for line in split(strip(str), "\n")
        left, right = split(line, ")")
        result[right] = left
    end
    result
end

# Depth first search the path a node takes to the root
function dfs(graph::Graph, start::String)::Array{String,1}
    result = []
    node = start
    while haskey(graph, node)
        node = graph[node]
        push!(result, node)
    end
    result
end

function orbital_checksum(graph::Graph)
    # Just use dfs to get the path of every node to COM
    # then total up the length of every path
    sum([length(dfs(graph, n)) for n in keys(graph)])
end

function num_transfers_between(graph, start, dest)
    # This is really easy. There is an identical path from COM to a node that
    # is the start of a branch. By treating each path as a set and finding only
    # the nodes that are unique to each set (symdiff), we have the answer
    start_to_com = dfs(graph, start)
    dest_to_com = dfs(graph, dest)
    part_two = length(symdiff(start_to_com, dest_to_com))
end

function solve()
    input = read("res/day_06.txt", String)
    graph = parse_graph(input)

    part_one = orbital_checksum(graph)
    part_two = num_transfers_between(graph, "YOU", "SAN")

    part_one, part_two
end

function run_tests()
    @testset "orbital_checksum" begin
        input = strip("""
        COM)B
        B)C
        C)D
        D)E
        E)F
        B)G
        G)H
        D)I
        E)J
        J)K
        K)L
        """)
        graph = parse_graph(input)
        @test dfs(graph, "D") == ["C", "B", "COM"]
        @test dfs(graph, "L") == ["K", "J", "E", "D", "C", "B", "COM"]
        @test orbital_checksum(graph) == 42
    end
end

solve()
