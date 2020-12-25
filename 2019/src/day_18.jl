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

function placebots!(grid::Grid)::Grid
    grid
    start = findfirst(==('@'), grid)
    changes = Dict(
        [-1, -1] => '@', [0, -1] => '#', [1, -1] => '$',
        [-1, 0] => '#', [0, 0] => '#', [1, 0] => '#',
        [-1, 1] => '%', [0, 1] => '#', [1, 1] => '&'
    )
    for (Δ, c) in changes
        (x, y) = [start[2], start[1]] + Δ
        grid[y, x] = c
    end
    grid
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

function dijkstra(graph::Graph)::Dict{Tuple{Char,Set{Char}},Int}
    result = Dict(('@', Set()) => 0)
    pq = BinaryHeap(Base.By(first), [(State(), '@')])

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

mutable struct QuadState
    steps::Vector{Int}
    keys::Vector{Set{Char}}
    QuadState() = new([0, 0, 0, 0], [Set(), Set(), Set(), Set()])
end

steps(qs::QuadState) = sum(qs.steps)
allkeys(qs::QuadState) = union(qs.keys...)

function isless(a::QuadState, b::QuadState)
    n = cmp(length(allkeys(a)), length(allkeys(b)))
    if n == 1
        true
    elseif n == 0
        steps(a) < steps(b)
    else
        false
    end
end

function quad_dijkstra(graph::Graph)::Dict{Tuple{Vector{Char},Set{Char}},Int}
    sources = ['@', '$', '%', '&']
    result = Dict((sources, Set()) => 0)
    pq = BinaryHeap(Base.By(first), [(QuadState(), sources)])

    while !isempty(pq)
        cur_state, nodes = pop!(pq)

        if steps(cur_state) > get!(result, (nodes, allkeys(cur_state)), typemax(Int))
            # Abort because this is a long path
            continue
        end

        for (i, node) in enumerate(nodes)
            for (neighbor, (weight, keys_needed)) in graph[node]
                neighbor, weight, keys_needed

                if !issubset(keys_needed, allkeys(cur_state))
                    # We don't have the keys to traverse here
                    continue
                end

                if lowercase(neighbor) in allkeys(cur_state)
                    # Don't visit uneccesary nodes
                    continue
                end

                next_state = deepcopy(cur_state)
                next_state.steps[i] += weight
                if neighbor in 'a':'z'
                    # We collected a key
                    push!(next_state.keys[i], neighbor)
                end

                # Only proceed if this path is better
                newnodes = replace(nodes, node => neighbor)
                if steps(next_state) < get!(result, (newnodes, allkeys(next_state)), typemax(Int))
                    result[(newnodes, allkeys(next_state))] = steps(next_state)
                    push!(pq, (next_state, newnodes))
                end
            end
        end
    end

    all = Set(k for k in keys(graph) if k in 'a':'z')
    Dict(k => v for (k, v) in result if k[2] == all)
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    part_one = input |> Grid |> Graph |> dijkstra |> values |> minimum
    part_two = input |> Grid |> placebots! |> Graph |> quad_dijkstra |> values |> minimum
    part_one, part_two
end

@time @show solve()
