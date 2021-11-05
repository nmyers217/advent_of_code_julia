function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    tickertape = Set([
        ("children", 3), ("cats", 7), ("samoyeds", 2), ("pomeranians", 3), ("akitas", 0),
        ("vizslas", 0), ("goldfish", 5), ("trees", 3), ("cars", 2), ("perfumes", 1),
    ])

    aunts = reduce(eachmatch(r".+ (\d+): (.+)", input), init=Dict()) do acc, m
        (n, rest) = m.captures
        compounds = map(split(strip(rest), ",")) do str
            (name, val) = strip.(split(str, ":"))
            (name, parse(Int, val))
        end |> Set
        acc[n] = compounds
        acc
    end

    partone = filter(aunts) do (aunt, compounds)
        issubset(compounds, tickertape)
    end |> first |> first

    parttwo = begin
        lookup = reduce(tickertape, init=Dict()) do acc, (name, val)
            acc[name] = val
            acc
        end

        filter(aunts) do (aunt, compounds)
            exacts, greater, fewer = Set(), [], []
            for (name, val) in compounds
                if name ∈ ["cats", "trees"]
                    push!(greater, (name, val))
                elseif name ∈ ["pomeranians", "goldfish"]
                    push!(fewer, (name, val))
                else
                    push!(exacts, (name, val))
                end
            end

            greatermatch = all(greater) do (name, val) val > lookup[name] end
            fewermatch = all(fewer) do (name, val) val < lookup[name] end
            issubset(exacts, tickertape) && greatermatch && fewermatch
        end |> first |> first
    end

    partone, parttwo
end

@time solve()
