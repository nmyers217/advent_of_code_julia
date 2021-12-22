struct Instruction
    target::AbstractString
    op::Function
    amount::Int
    source::AbstractString
    cond::Function
    condamount::Int

    Instruction(str) = begin
        rx = r"(\w+) (\w+) (\S+) \w+ (\w+) (\D+) (\S+)"
        m = match(rx, str)
        if isnothing(m) return end
        (target, op, amount, source, cond, condamount) = m.captures
        op = op == "inc" ? (+) : op == "dec" ? (-) : error("Invliad op: $op")
        cond = eval(Meta.parse(cond))
        amount, condamount = parse(Int, amount), parse(Int, condamount)
        new(target, op, amount, source, cond, condamount)
    end
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    instructions = Instruction.(split(strip(input), "\n"))

    registers, biggest = Dict(), 0
    for ins in instructions
        (s, t) = [get!(registers, k, 0) for k in [ins.source, ins.target]]
        if ins.cond(s, ins.condamount)
            amt = ins.op(t, ins.amount)
            registers[ins.target] = amt
            if amt > biggest biggest = amt end
        end
        registers
    end

    maximum(values(registers)), biggest
end

@time @show solve()
