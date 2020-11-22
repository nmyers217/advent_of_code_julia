include("IntCode.jl")
using .IntCode

struct Tile
    x::Int
    y::Int
    id::Int
end

function draw(grid::Array{Int,2}, score::Int)
    io = IOBuffer()
    for y in 1:size(grid, 1)
        for x in 1:size(grid, 2)
            c = grid[y, x]
            if c == 0
                print(io, ' ')
            elseif c == 1
                print(io, '▧')
            elseif c == 2
                print(io, '■')
            elseif c == 3
                print(io, '▬')
            elseif c == 4
                print(io, '●')
            else
                error("Bad tile at ($x, $y): $c")
            end
        end
        println(io)
    end
    println(String(take!(io)))
    println("Score: ", score)
end

function solve()
    input = read("res/day_13.txt", String)

    m = IntCodeMachine(input)

    advance_machine!(m)
    tiles = []
    while !isempty(m.stdout)
        push!(tiles, Tile(popfirst!(m.stdout), popfirst!(m.stdout), popfirst!(m.stdout)))
    end
    part_one = count(t -> t.id == 2, tiles)

    grid = begin
        (max_x, max_y) = (maximum(t -> t.x, tiles), maximum(t -> t.y, tiles))
        result = fill(0, (max_y + 1, max_x + 1))
        for tile in tiles
            result[tile.y + 1, tile.x + 1] = tile.id
        end
        result
    end

    m = IntCodeMachine(input)
    m.memory[1] = 2

    score = -Inf
    paddle_x = first(filter(t -> t.id == 3, tiles)).x
    ball_x = first(filter(t -> t.id == 4, tiles)).x

    while true
        # Set the joystick position by comparing the x coord of the ball and paddle
        push!(m.stdin, cmp(ball_x, paddle_x))

        # Advance the game
        advance_machine!(m)

        if (isempty(m.stdout))
            # No more outputs means the program is done
            break;
        end

        # Empty stdout and update the score, grid, and ball/paddle x coords
        while !isempty(m.stdout)
            (x, y, id) = (popfirst!(m.stdout), popfirst!(m.stdout), popfirst!(m.stdout))
            if x == -1 && y == 0
                score = id
            else
                grid[y + 1, x + 1] = id
                if id == 3
                    paddle_x = x
                end
                if id == 4
                    ball_x = x
                end
            end
        end

        # Visualize
        run(`clear`)
        draw(grid, score)
        sleep(1 / 2000) # make things a littlre more smooth
    end

    (part_one, score)
end

solve()
