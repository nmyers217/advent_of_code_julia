struct StateData
    write::Int64
    move::Int64
    cont::Char
    StateData(write::AbstractString, move::AbstractString, cont::AbstractString) = begin
        move = move == "right" ? 1 : -1
        new(parse(Int, write), move, cont[1])
    end
end

mutable struct TuringMachine
    tape::Vector{Int64}
    cursor::Int64
    steps::Int64
    curstate::Char
    checksumat::Int64
    states::Dict{Char, Dict{Int64, StateData}}

    TuringMachine(input::AbstractString) = begin
        (header, paragraphs...) = split(strip(input), "\n\n")
        m = match(r".* (\w+)\.\n.* (\d+) .*", header)
        if isnothing(m) error("Could not parse header!") end
        (curstate, checksumat) = m.captures

        states = Dict()
        for p in paragraphs
            m1 = match(r".*state (\w+):\n", p)
            m2 = eachmatch(r".* (\d+):\n.* (\d+)\.\n.* (\w+)\.\n.* (\w+)\.", p)
            if any(isnothing, [m1, m2]) error("Could not parse state!") end

            state = first(m1.captures)[1]
            states[state] = Dict()
            for m in m2
                (val, write, move, cont) = m.captures
                states[state][parse(Int, val)] = StateData(write, move, cont)
            end
        end

        new([0], 1, 0, curstate[1], parse(Int, checksumat), states)
    end
end

function run!(t::TuringMachine)
    while t.steps < t.checksumat
        statedata = t.states[t.curstate][t.tape[t.cursor]]
        t.tape[t.cursor] = statedata.write
        t.cursor += statedata.move
        if t.cursor == 0
            pushfirst!(t.tape, 0)
            t.cursor = 1
        elseif t.cursor == length(t.tape) + 1
            push!(t.tape, 0)
            t.cursor = length(t.tape)
        end
        t.curstate = statedata.cont
        t.steps += 1
    end
    t
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    count(==(1), run!(TuringMachine(input)).tape)
end

@time solve()
