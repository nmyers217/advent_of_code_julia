function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    skip = parse(Int, input)

    partone = begin
        # NOTE: circshift goes in the opposite direction you would think, so this array is backwards
        arr = [0]
        for n in 1:2018
            arr = circshift(arr, skip + 1)
            push!(arr, n)
        end

        after2017 = 0
        for (i, n) in enumerate(arr)
            if n == 2017
                after2017 = arr[mod1(i - 1, length(arr))]
                break
            end
        end
        after2017
    end

    parttwo = begin
        pos, afterzero = 0, -1
        for n in 1:50_000_000
            pos = (pos + skip) % n + 1
            if pos == 1; afterzero = n end
        end
        afterzero
    end

    partone, parttwo
end

@time solve()
