function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    password = strip(input)

    inc(str) = begin
        result = first.(split(str, ""))
        i, carryover = length(result), [1]
        while i >= 1 && !isempty(carryover)
            result[i] += pop!(carryover)
            if result[i] > 'z'
                result[i] = 'a'
                push!(carryover, 1)
            end
            i -= 1
        end
        join(result)
    end

    isvalidpassword(str) = begin
        hasstraight = false
        for i in eachindex(str)
            if str[i] ∈ ['i', 'o', 'l'] return false end
            if i >= 3 && str[i] == (str[i - 1] + 1) && str[i] == (str[i - 2] + 2)
                hasstraight = true
                break
            end
        end
        hasstraight && !isnothing(match(r".*(\w)\1.*(\w)\2.*", str))
    end

    nextpassword(str) = begin
        result = inc(str)
        while !isvalidpassword(result) result = inc(result) end
        result
    end

    partone = nextpassword(password)
    parttwo = nextpassword(partone)
    partone, parttwo
end

@time solve()
