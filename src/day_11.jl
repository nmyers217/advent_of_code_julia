# Programs will be padded with zeros at the end to be this large
const MEMORY_SIZE = 4096

mutable struct IntCodeMachine
    # The machine's memory
    memory::Array{Int64,1}
    # The instruction pointer
    ip::UInt
    # The relative base
    rb::Int
    # A queue for std input
    stdin::Array{Int64,1}
    # A queue for std output
    stdout::Array{Int64,1}
    # true if the machine is waiting on input but hasn't yet terminated
    is_halted::Bool
    # true if the program has already terminated
    terminated::Bool

    IntCodeMachine(memory::Array{Int,1}) = begin
        padded_mem = copy(memory)
        while length(padded_mem) < MEMORY_SIZE
            push!(padded_mem, 0)
        end
        new(padded_mem, 1, 0, [], [], false, false)
    end
end

function do_operation!(machine::IntCodeMachine)
    read!(mode=0) = begin
        machine.ip += 1
        if mode == 0
            machine.memory[machine.memory[machine.ip] + 1]
        elseif mode == 1
            machine.memory[machine.ip]
        elseif mode == 2
            machine.memory[machine.memory[machine.ip] + machine.rb + 1]
        else 
            error("Invalid parameter mode $mode")
        end
    end

    write!(val::Int, mode=0) = begin
        machine.ip += 1
        if mode == 0
            machine.memory[machine.memory[machine.ip] + 1] = val
        elseif mode == 1
            error("Immedate mode (mode 1) is not supported for writes")
        elseif mode == 2
            machine.memory[machine.memory[machine.ip] + machine.rb + 1] = val
        end
    end

    if machine.terminated
        return
    end

    op = machine.memory[machine.ip]
    opcode, modes = op % 100, digits(convert(Int, floor(op / 100)))
    while length(modes) < 3
        push!(modes, 0)
    end

    if machine.is_halted
        # The machine is halted, so let's check if it can be resumed yet
        if length(machine.stdin) == 0
            # Nope
            return
        else
            # There is new input, so it's good to go
            machine.is_halted = false
        end
    end

    if opcode == 99
        # Program has terminated
        machine.terminated = true
        return
    elseif opcode == 1
        write!(read!(modes[1]) + read!(modes[2]), modes[3])
        machine.ip += 1
    elseif opcode == 2
        write!(read!(modes[1]) * read!(modes[2]), modes[3])
        machine.ip += 1
    elseif opcode == 3
        if length(machine.stdin) == 0
            # We have to halt until we get more input
            machine.is_halted = true
            return
        end
        write!(popfirst!(machine.stdin), modes[1])
        machine.ip += 1
    elseif opcode == 4
        push!(machine.stdout, read!(modes[1]))
        machine.ip += 1
    elseif opcode == 5
        if (read!(modes[1]) != 0)
            machine.ip = read!(modes[2]) + 1
        else
            machine.ip += 2
        end
    elseif opcode == 6
        if (read!(modes[1]) == 0)
            machine.ip = read!(modes[2]) + 1
        else
            machine.ip += 2
        end
    elseif opcode == 7
        if (read!(modes[1]) < read!(modes[2]))
            write!(1, modes[3])
        else
            write!(0, modes[3])
        end
        machine.ip += 1
    elseif opcode == 8
        if (read!(modes[1]) == read!(modes[2]))
            write!(1, modes[3])
        else
            write!(0, modes[3])
        end
        machine.ip += 1
    elseif opcode == 9
        machine.rb += read!(modes[1])
        machine.ip += 1
    else
        error("Invalid opcode $opcode at address $(machine.ip)")
    end

end

function advance_machine!(machine::IntCodeMachine)
    while !machine.terminated
        do_operation!(machine)
        if machine.is_halted
            # There is nothing more to do until the machine gets more input
            return
        end
    end
end

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
        if dir_delta == 0
            dir = [y, -x]
        elseif dir_delta == 1
            dir = [-y, x]
        else
            error("invalid direction $dir_delta")
        end
        pos += dir
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
