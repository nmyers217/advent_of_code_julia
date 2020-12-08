using Test

struct Instruction
    name::String
    val::Int

    Instruction(name::AbstractString, val::Int) = begin
        if name ∉ ["acc", "jmp", "nop"]
            error("Invalid instruction $name")
        end
        new(name, val)
    end

    Instruction(str::AbstractString) = begin
        (name, val) = split(strip(str))
        new(name, parse(Int, val))
    end
end

mutable struct BootProgram
    acc::Int
    ip::UInt
    past_ip::Set{UInt}
    instructions::Vector{Instruction}

    BootProgram(str::AbstractString) = begin
        instructions = [Instruction(line) for line in split(strip(str), "\n")]
        new(0, 1, Set(), instructions)
    end
end

function run!(bp::BootProgram)
    while bp.ip ∉ bp.past_ip && bp.ip <= length(bp.instructions)
        push!(bp.past_ip, bp.ip)
        ins = bp.instructions[bp.ip]

        bp.ip += if ins.name == "acc"
            bp.acc += ins.val
            1
        elseif ins.name == "jmp"
            ins.val
        elseif ins.name == "nop"
            1
        else
            error("Invalid instruction $(ins.name)")
        end
    end
end

function fix_program(bp::BootProgram)
    ins_count = length(bp.instructions)
    for i in 1:ins_count
        bp_cpy = deepcopy(bp)

        ins = bp_cpy.instructions[i]
        if ins.name == "nop"
            bp_cpy.instructions[i] = Instruction("jmp", ins.val)
        elseif ins.name == "jmp"
            bp_cpy.instructions[i] = Instruction("nop", ins.val)
        else
            continue
        end

        run!(bp_cpy)

        if bp_cpy.ip > ins_count
            return bp_cpy.acc
        end
    end

    error("Program could not be fixed...")
end

function solve()
    input = read("2020/res/day_08.txt", String)
    part_one = begin
        bp = BootProgram(input)
        run!(bp)
        bp.acc
    end
    part_two = begin
        bp = BootProgram(input)
        fix_program(bp)
    end
    part_one, part_two
end

function run_tests()
    test_input = """
    nop +0
    acc +1
    jmp +4
    acc +3
    jmp -3
    acc -99
    acc +1
    jmp -4
    acc +6
    """
    bp = BootProgram(test_input)
    run!(bp)
    @test bp.acc == 5
    bp = BootProgram(test_input)
    @test fix_program(bp) == 8
end

run_tests()
solve()