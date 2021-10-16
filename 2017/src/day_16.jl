function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    progs, index = [], Dict()

    reset() = begin
        progs = collect('a':'p')
        index = reduce(enumerate(progs), init=Dict()) do index, (i, prog)
            index[prog] = i
            index
        end
    end

    dance() = begin
        for str in split(strip(input), ",")
            if startswith(str, 's')
                n = parse(Int, str[2:end])
                front = progs[end-(n-1):end]
                back = progs[1:end-n]
                progs = [front; back]
                for (i, p) in enumerate(progs)
                    index[p] = i
                end
            elseif startswith(str, 'x')
                (i, j) = [parse(Int, s) for s in split(str[2:end], "/")]
                i += 1
                j += 1
                a, b = progs[i], progs[j]
                progs[i] = b
                progs[j] = a
                index[a] = j
                index[b] = i
            elseif startswith(str, 'p')
                (a, b) = [s[1] for s in split(str[2:end], "/")]
                i, j = index[a], index[b]
                index[a] = j
                index[b] = i
                progs[i] = b
                progs[j] = a
            else
                error("Invalid instruction $str")
            end
        end
    end

    partone = begin
        reset()
        dance()
        join(progs)
    end

    parttwo = begin
        reset()
        seen, cycle = Set(), []
        for _ in 1:1_000_000_000
            dance()
            k = join(progs)
            if k in seen break end
            push!(seen, k)
            push!(cycle, k)
        end
        cycle[mod1(1_000_000_000, length(cycle))]
    end

    partone, parttwo
end

@time solve()
