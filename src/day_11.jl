include("IntCode.jl")
using .IntCode

function paint_hull(prog, start_color=0)::Dict{Array{Int,1},Int}
    result = Dict([0,0] => start_color)
    m = IntCodeMachine(prog)
    pos = [0, 0]
    dir = [0, -1]

    while !m.terminated
        # Input the color of the current square
        push!(m.stdin, get(result, pos, 0))

        # Advance the program until it halts
        advance_machine!(m)

        # Color the current position
        result[pos] = popfirst!(m.stdout)

        # Rotate and advance a square
        dir_delta = popfirst!(m.stdout)
        (x, y) = dir
        pos += if dir_delta == 0
            dir = [y, -x]
        elseif dir_delta == 1
            dir = [-y, x]
        else
            error("invalid direction $dir_delta")
        end
    end

    result
end

function render_hull(colors::Dict{Array{Int,1},Int})
    points = keys(colors)
    (min_x, max_x) = extrema(p -> p[1], points)
    (min_y, max_y) = extrema(p -> p[2], points)
    (width, height) = ((max_x - min_x) + 1, (max_y - min_y) + 1)
    image = fill(0, (height, width))

    for (x, y) in points
        image[y + 1, x + 1] = colors[[x, y]]
    end

    for y in 1:height
        for x in 1:width
            n = image[y, x]
            print(n == 1 ? "#" : " ")
        end
        print("\n")
    end
end

function solve()
    input = read("res/day_11.txt", String)
    program = [
        parse(Int, x) for x in split(strip(input), ",")
    ]

    colors = paint_hull(program)
    part_one = length(keys(colors))

    println(part_one)
    render_hull(paint_hull(program, 1))
end

solve()
