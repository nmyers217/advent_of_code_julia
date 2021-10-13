function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    stream = split(input, "")

    scorelevel, total, isgarbage, deleted = 0, 0, false, 0
    while !isempty(stream)
        c = popfirst!(stream)
        if c == "{"
            if !isgarbage
                scorelevel += 1
            else
                deleted += 1
            end
        elseif c == "}"
            if !isgarbage
                total += scorelevel
                scorelevel -= 1
            else
                deleted += 1
            end
        elseif c == "<"
            if !isgarbage
                isgarbage = true
            else
                deleted += 1
            end
        elseif c == ">"
            if isgarbage isgarbage = false end
        elseif c == "!"
            popfirst!(stream)
        else
            if isgarbage deleted += 1 end
        end
    end

    total, deleted
end

@time solve()
