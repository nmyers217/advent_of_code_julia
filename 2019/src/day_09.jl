using Test

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

function solve()
    input = read("2019/res/day_09.txt", String)
    program = [
        parse(Int, x) for x in split(strip(input), ",")
    ]

    m = IntCodeMachine(program)
    push!(m.stdin, 1)
    advance_machine!(m)

    @test length(m.stdout) == 1
    part_one = first(m.stdout)

    m = IntCodeMachine(program)
    push!(m.stdin, 2)
    advance_machine!(m)
    part_two = first(m.stdout)

    part_one, part_two
end

function run_tests()
    run(prog) = begin
        m = IntCodeMachine(prog)
        advance_machine!(m)
        m.stdout
    end

    @test run([109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]) == [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
    @test length(digits(first(run([1102,34915192,34915192,7,4,7,99,0])))) == 16
    @test run([104,1125899906842624,99]) == [1125899906842624]
end

solve()
