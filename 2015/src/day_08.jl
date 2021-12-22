function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    lines = strip.(split(strip(input), "\n"))

    partone = map(lines) do str
        codelen = length(str)
        memlen = (str |> unescape_string |> eval |> length) - 2
        codelen - memlen
    end |> sum

    parttwo = map(lines) do str
        2 + count(==('\\'), str)  + count(==('"'), str)
    end |> sum

    partone, parttwo
end

@time @show solve()
