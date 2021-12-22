function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    dims = map(eachmatch(r"(\d+)x(\d+)x(\d+)", strip(input))) do m
        tuple([parse(Int, n) for n in m.captures]...)
    end

    partone = reduce(dims, init=0) do result, (l, w, h)
        (lw, wh, lh) = (l * w, w * h, l * h)
        result + min(lw, wh, lh) + (2*lw + 2*wh + 2*lh)
    end

    parttwo = reduce(dims, init=0) do result, (l, w, h)
        wrap = min(l*2 + w*2, w*2 + h*2, l*2 + h*2)
        bow = l * w * h
        result + wrap + bow
    end

    partone, parttwo
end

@time @show solve()
