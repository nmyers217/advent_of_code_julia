using Test

abstract type Instruction end

struct MaskReset <: Instruction
    val::AbstractString
end

struct Assignment <: Instruction
    addr::UInt
    val::UInt
end

mutable struct Program
    mask::AbstractString
    instructions::Vector{Instruction}
    memory::Dict{Int,Int}

    Program(str::AbstractString) = begin
        instructions = map(split(strip(str), "\n")) do line
            (left, right) = split(line, " = ")

            if startswith(left, "mask")
                MaskReset(right)
            elseif startswith(left, "mem")
                m = match(r"mem\[(\d+)\]", left)
                if isnothing(m)
                    error("Invalid instruction $line")
                end
                addr = parse(UInt, first(m.captures))
                val = parse(UInt, right)
                Assignment(addr, val)
            else
                error("Invalid instruction $line")
            end
        end

        new(join('X' for _ in 1:36), instructions, Dict())
    end
end

function assignment!(p::Program, ins::Assignment; version=1)
    if version == 1
        val_bits = reverse(bitstring(ins.val))
        mask_bits = reverse(p.mask)
        new_bits = [m == 'X' ? v : m for (v, m) in zip(val_bits, mask_bits)]
        p.memory[ins.addr] = parse(UInt, reverse(join(new_bits)), base=2)
    else
        addr_bits = reverse(bitstring(ins.addr))
        mask_bits = reverse(p.mask)
        pairs = collect(zip(addr_bits, mask_bits))

        addresses::Vector{UInt} = []
        (recur_helper(addr, i) = begin
            if i > length(pairs)
                return push!(addresses, parse(UInt, reverse(join(addr)), base=2))
            end

            (addr_bit, mask_bit) = pairs[i]
            if mask_bit == '0'
                recur_helper([addr; addr_bit], i + 1)
            elseif mask_bit == '1'
                recur_helper([addr; '1'], i + 1)
            else
                recur_helper([addr; '0'], i + 1)
                recur_helper([addr; '1'], i + 1)
            end
        end)([], 1)

        for addr in addresses
            p.memory[addr] = ins.val
        end
    end
end

function run!(p::Program; version=1)
    if isempty(p.instructions)
        return
    end

    ins = popfirst!(p.instructions)

    if typeof(ins) == MaskReset
        p.mask = ins.val
    elseif typeof(ins) == Assignment
        assignment!(p, ins; version=version)
    else
        "Invalid instruction $ins"
    end

    run!(p; version=version)
end

function solve()
    input = read("2020/res/day_14.txt", String)

    part_one = begin
        prog = Program(input)
        run!(prog)
        sum(values(prog.memory))
    end

    part_two = begin
        prog = Program(input)
        run!(prog; version=2)
        sum(values(prog.memory))
    end

    part_one, part_two
end

function run_tests()
    begin
        test_input = """
        mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
        mem[8] = 11
        mem[7] = 101
        mem[8] = 0
        """
        prog = Program(test_input)
        run!(prog)
        @test sum(values(prog.memory)) == 165
    end
    begin
        test_input = """
        mask = 000000000000000000000000000000X1001X
        mem[42] = 100
        mask = 00000000000000000000000000000000X0XX
        mem[26] = 1
        """
        prog = Program(test_input)
        run!(prog; version=2)
        @test sum(values(prog.memory)) == 208
    end
end

run_tests()
@time solve()