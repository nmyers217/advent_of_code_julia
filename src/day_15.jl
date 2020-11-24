include("IntCode.jl")
using .IntCode

struct Grid
    droid_pos::Vector{Int}
    oxygen_sys_pos::Vector{Int}
    cells::Array{String,2}

    # Constructs a grid from a mapping of positions to cell type
    Grid(cell_lookup::Dict{Vector{Int},String}) = begin
        points = collect(keys(cell_lookup))
        (min_x, max_x) = extrema(map(p -> p[1], points))
        (min_y, max_y) = extrema(map(p -> p[2], points))
        (width, height) = (max_x - min_x + 1, max_y - min_y + 1)

        # Get a vec that will translate the origin to be at 0,0
        # and then translate it again to make zero based positions 1 based
        origin_translate = [0, 0] - [min_x, min_y] + [1, 1]
        droid_pos = [0, 0] + origin_translate
        oxygen_sys_pos = [0, 0]
        cells = fill(" ", (height, width))

        for p in points
            val = cell_lookup[p]
            (x, y) = p + origin_translate
            cells[y, x] = val
            if val == "*"
                oxygen_sys_pos = [x, y]
            end
        end

        new(droid_pos, oxygen_sys_pos, cells)
    end
end

function Base.show(io::IO, grid::Grid)
    for y in 1:size(grid.cells, 1)
        for x in 1:size(grid.cells, 2)
            print(io, grid.cells[y, x])
        end
        println(io)
    end
end

function explore_cells!(m::IntCodeMachine)::Dict{Vector{Int},String}
    visited_cells = Dict([0, 0] => "D")
    pos_stack = [[0, 0]]

    move_droid!(dir) = begin
        input = Dict([0, -1] => 1, [0, 1] => 2, [-1, 0] => 3, [1, 0] => 4)[dir]
        push!(m.stdin, input)
        advance_machine!(m)
        if length(m.stdout) != 1
            error("Invalid machine output")
        end
        popfirst!(m.stdout)
    end

    while true
        # Get our current position
        pos = pos_stack[end]

        # Get the unexplored directions we can travel in
        dirs_to_explore = filter([[0, -1], [1, 0], [0, 1], [-1, 0]]) do dir
            !haskey(visited_cells, pos + dir)
        end

        if isempty(dirs_to_explore)
            # This is a dead end, so lets backtrack the machine
            cur_pos = pop!(pos_stack)
            if isempty(pos_stack)
                # We are back to the beginning and we explored everything!
                break
            end
            prev_pos = pos_stack[end]
            back_dir = prev_pos - cur_pos
            output = move_droid!(back_dir)
            if output != 1 && output != 2
                error("Droid could not backtrack from $cur_pos to $prev_pos with $back_dir")
            end
            continue
        end

        # Grab the first valid direction and explore it
        dir = first(dirs_to_explore)
        neighbor = pos + dir
        output = move_droid!(dir)
        visited_cells[neighbor] = if output == 0
            # The neighbor in this dir is a wall, track it but don't move
            "#"
        elseif output == 1
            # Neighbor in this dir is empty, track it and move there
            push!(pos_stack, neighbor)
            " "
        elseif output == 2
            # Neighbor is the oxygen system, track it and move there
            push!(pos_stack, neighbor)
            "*"
        else
            error("Invalid droid output $output")
        end
    end

    visited_cells
end

function breadth_first_search(
    grid::Grid,
    start::Vector{Int},
    dest::Union{Nothing,Vector{Int}}
)
    came_from = Dict()
    visited = Set([start])
    q = [start]
    longest_length = 0

    traceback_path(pos) = begin
        parent = came_from[pos]
        path_taken = [parent]
        while haskey(came_from, parent)
            parent = came_from[parent]
            push!(path_taken, parent)
        end
        reverse(path_taken)
    end

    while !isempty(q)
        pos = popfirst!(q)

        if !isnothing(dest) && pos == dest
            return length(traceback_path(pos))
        end

        dirs = filter([[0,-1], [1,0], [0,1], [-1,0]]) do dir
            (x, y) = pos + dir
            [x, y] ∉ visited && grid.cells[y, x] != "#"
        end

        if isnothing(dest) && isempty(dirs)
            longest_length = max(longest_length, length(traceback_path(pos)))
            continue
        end

        for dir in dirs
            neighbor = pos + dir
            push!(q, neighbor)
            push!(visited, neighbor)
            came_from[neighbor] = pos
        end
    end

    longest_length
end

function breadth_first_search(grid::Grid)
    breadth_first_search(grid, grid.droid_pos, grid.oxygen_sys_pos)
end

function solve()
    input = read("res/day_15.txt", String)
    grid = Grid(explore_cells!(IntCodeMachine(input)))
    show(grid)
    part_one = breadth_first_search(grid)
    part_two = breadth_first_search(grid, grid.oxygen_sys_pos, nothing)
    (part_one, part_two)
end

solve()
