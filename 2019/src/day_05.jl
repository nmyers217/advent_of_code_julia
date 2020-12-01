using Test

mutable struct IntCodeMachine
    # The machine's memory
    memory::Array{Int,1}
    # The instruction pointer
    ip::UInt
    # A queue for std input
    stdin::Array{Int,1}
    # A queue for std output
    stdout::Array{Int,1}
    # true if the machine is waiting on input but hasn't yet terminated
    is_halted::Bool
    # true if the program has already terminated
    terminated::Bool

    IntCodeMachine(memory::Array{Int,1}) = new(copy(memory), 1, [], [], false, false)
end

function do_operation!(machine::IntCodeMachine)
    read!(mode=0) = begin
        machine.ip += 1
        if mode == 0
            machine.memory[machine.memory[machine.ip] + 1]
        elseif mode == 1
            machine.memory[machine.ip]
        else 
            error("Invalid parameter mode $mode")
        end
    end

    write!(val::Int) = begin
        machine.ip += 1
        machine.memory[machine.memory[machine.ip] + 1] = val
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
        write!(read!(modes[1]) + read!(modes[2]))
        machine.ip += 1
    elseif opcode == 2
        write!(read!(modes[1]) * read!(modes[2]))
        machine.ip += 1
    elseif opcode == 3
        if length(machine.stdin) == 0
            # We have to halt until we get more input
            machine.is_halted = true
            return
        end
        write!(popfirst!(machine.stdin))
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
            write!(1)
        else
            write!(0)
        end
        machine.ip += 1
    elseif opcode == 8
        if (read!(modes[1]) == read!(modes[2]))
            write!(1)
        else
            write!(0)
        end
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
    open("2019/res/day_05.txt") do input_file
        program = [
            parse(Int, x) for x in split(strip(read(input_file, String)), ",")
        ]

        m = IntCodeMachine(program)
        push!(m.stdin, 1)
        advance_machine!(m)

        @test all(n -> n == 0, m.stdout[1:(end - 1)])

        part_one = m.stdout[end]

        m = IntCodeMachine(program)
        push!(m.stdin, 5)
        advance_machine!(m)

        part_two = m.stdout[end]

        part_one, part_two
    end
end

function run_tests()
    run(prog, inputs) = begin
        m = IntCodeMachine(prog)
        push!(m.stdin, inputs...)
        advance_machine!(m)
        m.stdout
    end
    @testset "IntCodeMachine" begin
        @test run([3,9,8,9,10,9,4,9,99,-1,8], [8]) == [1]
        @test run([3,9,8,9,10,9,4,9,99,-1,8], [9]) == [0]
        @test run([3,9,7,9,10,9,4,9,99,-1,8], [7]) == [1]
        @test run([3,9,7,9,10,9,4,9,99,-1,8], [8]) == [0]

        @test run([3,3,1108,-1,8,3,4,3,99], [8]) == [1]
        @test run([3,3,1108,-1,8,3,4,3,99], [9]) == [0]
        @test run([3,3,1107,-1,8,3,4,3,99], [7]) == [1]
        @test run([3,3,1107,-1,8,3,4,3,99], [8]) == [0]

        @test run([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], [0]) == [0]
        @test run([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], [5]) == [1]
        @test run([3,3,1105,-1,9,1101,0,0,12,4,12,99,1], [0]) == [0]
        @test run([3,3,1105,-1,9,1101,0,0,12,4,12,99,1], [5]) == [1]
    end
end

solve()

