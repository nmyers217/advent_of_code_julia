# Get DataStructures.jl
using Pkg
Pkg.add("DataStructures")
using DataStructures

const Grid = Array{Char,2}
function Grid(str::AbstractString)::Grid
    lines = split(strip(str), "\n")
    rows, cols = length(lines), length(first(lines))
    result = fill('.', (rows, cols))
    for (y, row) in enumerate(lines)
        for (x, c) in enumerate(s[1] for s in split(row, ""))
            result[y, x] = c
        end
    end
    result
end

function bfs(grid::Grid, source::Vector{Int})::Dict{Char,Tuple{Int,Set{Char}}}
    result = Dict()
    visited = Set([source])
    prev = Dict()

    trace(point) = begin
        steps = 0
        keys = Set()
        while haskey(prev, point)
            steps += 1
            c = grid[point[2], point[1]]
            if c in 'A':'Z'
                push!(keys, lowercase(c))
            end
            point = prev[point]
        end
        steps, keys
    end

    q = [source]
    while !isempty(q)
        cur = popfirst!(q)
        neighbors = map(n -> n + cur, [[-1, 0], [0, -1], [1, 0], [0, 1]])
        for n in neighbors
            (x, y) = n
            in_bounds = 0 < y < size(grid, 1) && 0 < x < size(grid, 2)

            if n in visited || !in_bounds || grid[y, x] == '#'
                continue
            end

            c = grid[y, x]
            push!(visited, n)
            prev[n] = cur
            push!(q, n)

            if c != '.'
                result[c] = trace(n)
            end
        end
    end

    result
end

const Graph = Dict{Char,Dict{Char,Tuple{Int,Set{Char}}}}
function Graph(grid::Grid)::Graph
    result::Graph = Dict()
    for y in axes(grid, 1), x in axes(grid, 2)
        c = grid[y, x]
        if c ∉ ['#', '.']
            result[c] = bfs(grid, [x, y])
        end
    end
    result
end

mutable struct State
    steps::Int
    keys::Set{Char}
    State() = new(0, Set())
end

import Base.isless
function isless(a::State, b::State)
    n = cmp(length(a.keys), length(b.keys))
    if n == 1
        true
    elseif n == 0
        a.steps < b.steps
    else
        false
    end
end

function dijkstra(graph::Graph, source::Char='@')::Dict{Tuple{Char,Set{Char}},Int}
    result = Dict((source, Set()) => 0)
    pq = BinaryHeap(Base.By(first), [(State(), source)])

    while !isempty(pq)
        cur_state, node = pop!(pq)

        if cur_state.steps > get!(result, (node, cur_state.keys), typemax(Int))
            # Abort because this is a long path
            continue
        end

        for (neighbor, (weight, keys_needed)) in graph[node]
            neighbor, weight, keys_needed

            if !issubset(keys_needed, cur_state.keys)
                # We don't have the keys to traverse here
                continue
            end

            if lowercase(neighbor) in cur_state.keys
                # Don't visit uneccesary nodes
                continue
            end

            next_state = deepcopy(cur_state)
            next_state.steps += weight
            if neighbor in 'a':'z'
                # We collected a key
                push!(next_state.keys, neighbor)
            end

            # Only proceed if this path is better
            if next_state.steps < get!(result, (neighbor, next_state.keys), typemax(Int))
                result[(neighbor, next_state.keys)] = next_state.steps
                push!(pq, (next_state, neighbor))
            end
        end
    end

    all_keys = Set(k for k in keys(graph) if k in 'a':'z')
    Dict((k[1], k[2]) => v for (k, v) in result if k[2] == all_keys)
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    test_input = """
########################
#@..............ac.GI.b#
###d#e#f################
###A#B#C################
###g#h#i################
########################
"""

    input |> Grid |> Graph |> dijkstra |> values |> minimum
end

@time @show solve()
