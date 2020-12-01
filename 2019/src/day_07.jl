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

function setup_amplifiers(program, phases)::Array{IntCodeMachine,1}
    machines = map(phases) do phase
        m = IntCodeMachine(copy(program))
        push!(m.stdin, phase)
        m
    end
    push!(machines[1].stdin, 0)
    machines
end

function run_amplifiers!(amplifiers::Array{IntCodeMachine,1})
    last_outputs = []
    i = 1
    while true
        m = amplifiers[i]
        while length(last_outputs) > 0
            push!(m.stdin, popfirst!(last_outputs))
        end
        advance_machine!(m)
        while length(m.stdout) > 0
            push!(last_outputs, popfirst!(m.stdout))
        end
        if i == length(amplifiers) && m.terminated
            return last_outputs[end]
        else
            i += 1
            if i > length(amplifiers)
                i = mod1(i, length(amplifiers))
            end
        end
    end
end

function permutations(min=0, max=5)
    result = []

    (recur_helper(arr) = begin
        if length(arr) == (max - min)
            return push!(result, arr)
        end

        for n in min:(max - 1)
            if !(n in arr)
                recur_helper([arr..., n])
            end
        end
    end)([])

    result
end

function solve()
    open("2019/res/day_07.txt") do input_file
        program = [
            parse(Int, x) for x in split(strip(read(input_file, String)), ",")
        ]

        max = -Inf
        for phases in permutations()
            output = run_amplifiers!(setup_amplifiers(program, phases))
            if output > max
                max = output
            end
        end
        part_one = max

        max = -Inf
        for phases in permutations(5, 10)
            output = run_amplifiers!(setup_amplifiers(program, phases))
            if output > max
                max = output
            end
        end
        part_two = max

        part_one, part_two
    end
end

function run_tests()
    @testset "run_amplifiers!" begin
        @test run_amplifiers!(setup_amplifiers([3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0], [4,3,2,1,0])) == 43210
        @test run_amplifiers!(setup_amplifiers([3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0], [0,1,2,3,4])) == 54321
        @test run_amplifiers!(setup_amplifiers([3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0], [1,0,4,3,2])) == 65210

        @test run_amplifiers!(setup_amplifiers([3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5], [9,8,7,6,5])) == 139629729
        @test run_amplifiers!(setup_amplifiers([3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10], [9,7,8,5,6])) == 18216
    end
end

solve()