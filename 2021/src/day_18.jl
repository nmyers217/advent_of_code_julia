function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    combine(left, right) = ['[', left..., right..., ']']

    explode!(snailfish) = begin
        level = 0
        for i in eachindex(snailfish)
            if snailfish[i] == '['; level += 1 end
            if snailfish[i] == ']'; level -= 1 end
            if level == 5
                for j in i-1:-1:1
                    if typeof(snailfish[j]) <: Int
                        snailfish[j] += snailfish[i + 1]
                        break
                    end
                end

                for j in i+3:length(snailfish)
                    if typeof(snailfish[j]) <: Int
                        snailfish[j] += snailfish[i + 2]
                        break
                    end
                end

                for _ in 1:3 splice!(snailfish, i) end
                snailfish[i] = 0
                return true
            end
        end
        false
    end

    split!(snailfish) = begin
        for i in eachindex(snailfish)
            if typeof(snailfish[i]) <: Int && snailfish[i] >= 10
                left = convert(Int, floor(snailfish[i] / 2))
                right = convert(Int, ceil(snailfish[i] / 2))
                splice!(snailfish, i, combine(left, right))
                return true
            end
        end
        false
    end

    reduce!(snailfish) = begin
        while explode!(snailfish) || split!(snailfish)
        end
        snailfish
    end

    magnitude(snailfish::Any) = begin
        while !(typeof(snailfish[1]) <: Int)
            for i in eachindex(snailfish)
                if typeof(snailfish[i]) <: Int && typeof(snailfish[i + 1]) <: Int
                    mag = 3 * snailfish[i] + 2 * snailfish[i+1]
                    for _ in 1:3; splice!(snailfish, i) end
                    snailfish[i-1] = mag
                    break
                end
            end
        end
        return snailfish[1]
    end

    lines = map(split(strip(input), "\n")) do line
        map([c for c in first.(split(strip(line), "")) if c != ',']) do c
            if c in '0':'9'
                parse(Int, c)
            else
                c
            end
        end
    end

    partone = begin
        result = reduce(lines[2:end], init=lines[1]) do result, line
            reduce!(combine(result, line))
        end
        magnitude(result)
    end

    # NOTE: this takes like 2 minutes to run but this problem was so annoying that im not going to fix it
    parttwo = begin
        mags = []
        for i in eachindex(lines), j in eachindex(lines)
            push!(mags, reduce!(combine(lines[i], lines[j])) |> magnitude)
            push!(mags, reduce!(combine(lines[j], lines[i])) |> magnitude)
        end
        maximum(mags)
    end

    partone, parttwo
end

@time solve()