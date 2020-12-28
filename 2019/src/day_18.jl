# Get DataStructures.jl
using Pkg
Pkg.add("DataStructures")
using DataStructures
import Base.isless

const Grid = Array{Char,2}
const Graph = Dict{Char,Dict{Char,Tuple{Int,Set{Char}}}}

struct SearchState
    steps::Vector{Int}
    keys::Vector{Set{Char}}
    totalsteps::Int
    totalkeys::Set{Char}

    SearchState(i::Int) = new([0 for _ in 1:i], [Set() for _ in 1:i], 0, Set())
    SearchState(steps::Vector{Int}, keys::Vector{Set{Char}}) = begin
        new(steps, keys, sum(steps), union(keys...))
    end
    SearchState(s::SearchState, weight::Int, key::Union{Char,Nothing}, i::Int) = begin
        steps = copy(s.steps)
        keys = deepcopy(s.keys)
        steps[i] += weight
        if !isnothing(key)
            push!(keys[i], key)
        end
        SearchState(steps, keys)
    end
end

g(s::SearchState) = s.totalsteps
h(s::SearchState) = s.totalsteps - length(s.totalkeys) * 10
fscore(s::SearchState) = g(s) + h(s)

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

function astar(graph::Graph, sources::Vector{Char})
    all = Set(k for k in keys(graph) if k in 'a':'z')
    result = Dict((sources, Set()) => 0)
    pq = PriorityQueue{Tuple{SearchState,Vector{Char}},Int}()
    start_state = SearchState(length(sources))
    enqueue!(pq, (start_state, sources), fscore(start_state))

    while !isempty(pq)
        cur_state, nodes = dequeue!(pq)

        if cur_state.totalkeys == all
            # We found the destination
            return cur_state.totalsteps
        end

        if cur_state.totalsteps > get!(result, (nodes, cur_state.totalkeys), typemax(Int))
            # Abort because this is a long path
            continue
        end

        for (i, node) in enumerate(nodes)
            for (neighbor, (weight, keys_needed)) in graph[node]
                if !issubset(keys_needed, cur_state.totalkeys)
                    # We don't have the keys to traverse here
                    continue
                end

                if lowercase(neighbor) in cur_state.totalkeys
                    # Don't visit uneccesary nodes
                    continue
                end

                pickedup = neighbor in 'a':'z' ? neighbor : nothing
                next_state = SearchState(cur_state, weight, pickedup, i)

                # Only proceed if this path is better
                newnodes = replace(nodes, node => neighbor)
                if next_state.totalsteps < get!(result, (newnodes, next_state.totalkeys), typemax(Int))
                    result[(newnodes, next_state.totalkeys)] = next_state.totalsteps
                    enqueue!(pq, (next_state, newnodes), fscore(next_state))
                end
            end
        end
    end
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    part_one = begin
        g = input |> Grid |> Graph
        astar(g, ['@'])
    end
    part_two = begin
        g = input |> Grid |> placebots! |> Graph
        astar(g, ['@', '$', '%', '&'])
    end
    part_one, part_two
end

@time @show solve()
