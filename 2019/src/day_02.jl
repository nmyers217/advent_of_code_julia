function run_program!(program::Array{Int,1})
    ip = 1

    read!() = begin
        ip += 1
        program[program[ip] + 1]
    end

    write!(val::Int) = begin
        ip += 1
        program[program[ip] + 1] = val
    end

    while ip < length(program)
        opcode = program[ip]

        if opcode == 99
            return
        elseif opcode == 1
            write!(read!() + read!())
            ip += 1
        elseif opcode == 2
            write!(read!() * read!())
            ip += 1
        else
            error("Invalid opcode $opcode at address $ip")
        end
    end
end

function solve()
    open("2019/res/day_02.txt") do input_file
        program = [
            parse(Int, x) for x in split(strip(read(input_file, String)), ",")
        ]

        setup_and_run(noun, verb) = begin
            prog = copy(program)
            prog[2] = noun
            prog[3] = verb
            run_program!(prog)
            prog[1]
        end

        println(setup_and_run(12, 2))

        for noun in 0:99
            for verb in 0:99
                if setup_and_run(noun, verb) == 19690720
                    println(100 * noun + verb)
                    return
                end
            end
        end
    end
end

solve()
