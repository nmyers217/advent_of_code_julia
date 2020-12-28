include("IntCode.jl")
using .IntCode

function compile(script::AbstractString)::Vector{Int}
    convert.(Int, first.(split(script, "")))
end

function draw(ascii::Vector{Any})
    println(join(convert.(Char, ascii)))
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    walk_across_script = """
    NOT C J
    AND D J
    NOT A T
    OR T J
    WALK
    """

    run_across_script = """
    NOT C J
    AND D J
    AND H J
    NOT A T
    OR T J
    NOT B T
    AND D T
    OR T J
    RUN
    """

    execute(script) = begin
        result = nothing
        m = IntCodeMachine(input)
        append!(m.stdin, compile(script))
        advance_machine!(m)
        output = []
        while !isempty(m.stdout)
            val = popfirst!(m.stdout)
            if val > 256
                result = val
            else
                push!(output, val)
            end
        end
        draw(output)
        result
    end

    execute(walk_across_script), execute(run_across_script)
end

@time @show solve()
