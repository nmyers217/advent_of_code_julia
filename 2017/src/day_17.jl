function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    skip = parse(Int, input)

    # NOTE: circshift goes in the opposite direction you would think, so this array is backwards
    arr = [0]

    findvalafter(target) = begin
        for (i, n) in enumerate(arr)
            if n == target
                return arr[mod1(i - 1, length(arr))]
            end
        end
    end

    partone = begin
        for n in 1:2018
            arr = circshift(arr, skip + 1)
            push!(arr, n)
        end
        findvalafter(2017)
    end

    parttwo = begin
        for n in 2019:50_000_000
            println(n)
            # if n % 100_000 == 0
            #     println(n)
            # end
            arr = circshift(arr, skip + 1)
            push!(arr, n)
        end
        findvalafter(0)
    end

    partone, parttwo
end

@time solve()
