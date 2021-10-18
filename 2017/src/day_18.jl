mutable struct Tablet
    prog
    registers
    stdin
    stdout
    ip
    ishalted
    amountsent
    recieved
    Tablet(input) = begin
        prog = map(split(strip(input), "\n")) do line
            (op, rest...) = split(strip(line), " ")
            rest = [str[1] in 'a':'z' ? str[1] : parse(Int, str) for str in rest]
            if length(rest) === 1; rest = [rest; nothing] end
            (op, rest...)
        end
        new(prog, Dict(), [], [], 1, false, 0, [])
    end
end

function advance!(t::Tablet; duetmode=false)
    read!(val) = val in 'a':'z' ? get!(t.registers, val, 0) : val
    write!(reg, val) = t.registers[reg] = val

    if t.ishalted && isempty(t.stdin)
        println("Cant resume")
        return
    end

    if t.ishalted && !isempty(t.stdin)
        println("Resuming")
        t.ishalted = false
    end

    while t.ip in 1:length(t.prog)
        (op, x, y) = t.prog[t.ip]
        println("$op $x $y")

        if op == "snd"
            println("Sending $(read!(x))")
            push!(t.stdout, read!(x))
            t.amountsent += 1
            t.ip += 1
        elseif op == "set"
            write!(x, read!(y))
            t.ip += 1
        elseif op == "add"
            write!(x, read!(x) + read!(y))
            t.ip += 1
        elseif op == "mul"
            write!(x, read!(x) * read!(y))
            t.ip += 1
        elseif op == "mod"
            write!(x, read!(x) % read!(y))
            t.ip += 1
        elseif op == "rcv"
            if read!(x) != 0 || duetmode
                if isempty(t.stdin)
                    println("Halting")
                    t.ishalted = true
                    return
                end
                println("Recieving $(t.stdin[1])")
                push!(t.recieved, popfirst!(t.stdin))
            end
            t.ip += 1
        elseif op == "jgz"
            t.ip += read!(x) > 0 ? read!(y) : 1
        else
            error("Invalid operation $op")
        end
    end

    println("Prog finished")
    t.ishalted = true
    t.stdin = []
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    partone = begin
        t = Tablet(input)
        t.stdout = t.stdin # pipe tablet's IO into itself
        advance!(t)
        last(t.recieved)
    end

    # input = """
    # snd 1
    # snd 2
    # snd p
    # rcv a
    # rcv b
    # rcv c
    # rcv d
    # """

    parttwo = begin
        # Set up two tablets for a duet
        a, b = Tablet(input), Tablet(input)
        a.registers['p'] = 0
        b.registers['p'] = 1
        a.stdin = b.stdout
        b.stdin = a.stdout

        while any(t -> !t.ishalted || !isempty(t.stdin), [a, b])
            println()
            println("====")
            advance!(a, duetmode=true)

            println()
            println("****")
            advance!(b, duetmode=true)
        end

        length(a.recieved)
    end

    partone, parttwo
end

@time solve()
