##
## NOTE: a lot of this code is from day 18
##
mutable struct Cpu
    prog
    registers
    ip
    Cpu(input) = begin
        prog = map(split(strip(input), "\n")) do line
            (op, rest...) = split(strip(line), " ")
            rest = [str[1] in 'a':'z' ? str[1] : parse(Int, str) for str in rest]
            if length(rest) === 1; rest = [rest; nothing] end
            (op, rest...)
        end
        new(prog, Dict(), 1)
    end
end

function sieve(n :: Int)
    isprime = trues(n)
    isprime[1] = false
    for p in 2:n
        if isprime[p]
            j = p * p
            if j > n
                return findall(isprime)
            else
                for k in j:p:n
                  isprime[k] = false
                end
            end
        end
    end
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    cpu, muls = Cpu(input), 0

    run(;debug=false, verbose=false) = begin
        read!(val) = val in 'a':'z' ? get!(cpu.registers, val, 0) : val
        write!(reg, val) = cpu.registers[reg] = val

        while cpu.ip in 1:length(cpu.prog)
            (op, x, y) = cpu.prog[cpu.ip]

            if debug; println("$op $x $y") end
            if debug && verbose; println(cpu.registers) end

            if op == "set"
                write!(x, read!(y))
                cpu.ip += 1
            elseif op == "sub"
                write!(x, read!(x) - read!(y))
                cpu.ip += 1
            elseif op == "mul"
                muls += 1
                write!(x, read!(x) * read!(y))
                cpu.ip += 1
            elseif op == "jnz"
                cpu.ip += read!(x) != 0 ? read!(y) : 1
            else
                error("Invalid operation: $op")
            end
        end
    end

    partone = begin
        run()
        muls
    end

    parttwo = begin
        cpu = Cpu(input)
        # Only keep the portion of the program that sets up the initial registers
        cpu.prog = cpu.prog[1:8]
        cpu.registers['a'] = 1 # disable debug mode
        run()
        # Now all the registers are primed, but instead of running the optimized
        # code we will just run our own optimized version.
        # After reading the assembly, the program works as follows:
        #   1. Iteratesthrough ever value from b to c + 1 by a step of 17
        #   2. Brute force check all potential divisors to see if b is prime
        #   3. If prime don't inc h, otherwise inc h
        startb, startc = cpu.registers['b'], cpu.registers['c']
        primes = Set(sieve(startc))
        count(n -> n ∉ primes, startb:17:(startc + 1))
    end

    partone, parttwo
end

@time @show solve()
