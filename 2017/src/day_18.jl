mutable struct Tablet
    prog
    registers
    stdin
    stdout
    ip
    ishalted
    recieved
    Tablet(input) = begin
        prog = map(split(strip(input), "\n")) do line
            (op, rest...) = split(strip(line), " ")
            rest = [str[1] in 'a':'z' ? str[1] : parse(Int, str) for str in rest]
            if length(rest) === 1; rest = [rest; nothing] end
            (op, rest...)
        end
        new(prog, Dict(), [], [], 1, false, [])
    end
end

function advance!(t::Tablet; duetmode=false, debug=false, verbose=false)
    read!(val) = val in 'a':'z' ? get!(t.registers, val, 0) : val
    write!(reg, val) = t.registers[reg] = val

    if t.ishalted && isempty(t.stdin)
        if debug; println("Cant resume...") end
        return
    end

    if t.ishalted && !isempty(t.stdin)
        if debug; println("Resuming...") end
        t.ishalted = false
    end

    while t.ip in 1:length(t.prog)
        (op, x, y) = t.prog[t.ip]
        if debug && verbose; println("$op $x $y") end

        if op == "snd"
            if debug; println("Sending: $(read!(x))") end
            pushfirst!(t.stdout, read!(x))
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
            if isempty(t.stdin)
                if debug; println("Halting...") end
                t.ishalted = true
                return
            end

            val = pop!(t.stdin)

            if duetmode 
                write!(x, val)
                push!(t.recieved, val)
                if debug; println("Recieved: $val") end
            else
                if read!(x) != 0
                    push!(t.recieved, val)
                    if debug; println("Recieved $val") end
                end
            end

            t.ip += 1
        elseif op == "jgz"
            t.ip += read!(x) > 0 ? read!(y) : 1
        else
            error("Invalid operation: $op")
        end
    end

    if debug; println("Program Terminated...") end
    t.ishalted = true
end

function isterminated(t::Tablet)
    isdeadlocked = t.ishalted && isempty(t.stdin)
    outofbounds = t.ip < 1 || t.ip > length(t.prog)
    isdeadlocked || outofbounds
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    partone = begin
        t = Tablet(input)
        t.stdout = t.stdin # pipe tablet's IO into itself
        advance!(t)
        last(t.recieved)
    end

    parttwo = begin
        # Set up two tablets for a duet
        a, b = Tablet(input), Tablet(input)
        a.registers['p'] = 0
        b.registers['p'] = 1
        a.stdin = b.stdout
        b.stdin = a.stdout

        while any(t -> !isterminated(t), [a, b])
            advance!.([a, b], duetmode=true)
        end

        length(a.recieved)
    end

    partone, parttwo
end

@time @show solve()
