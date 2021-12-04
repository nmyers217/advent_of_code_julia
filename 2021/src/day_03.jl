function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    strings = split(strip(input), "\n")

    nums = begin
        result = fill(0, (strings |> length, strings |> first |> length))
        for (y, str) in enumerate(strings)
            for (x, c) in enumerate(str)
                result[y, x] = parse(Int, c)
            end
        end
        result
    end

    partone = begin
        numcolumns = size(nums, 2)

        gamma = map(1:numcolumns) do x
            col = nums[:, x]
            count(==(1), col) > count(==(0), col) ? 1 : 0
        end

        epsilon = map(gamma) do n
            n == 1 ? 0 : 1
        end

        parse(Int, "0b$(join(gamma))") * parse(Int, "0b$(join(epsilon))")
    end

    tomatrix(arr) = hcat(reverse(arr)...) |> rotl90

    filternums(f, nums) = begin
        result = copy(nums)
        x = 1
        while size(result, 1) > 1 && x <= size(result, 2)
            col = result[:, x]
            keepbit = f(col)
            result = filter(row -> row[x] == keepbit, eachrow(result) |> collect) |> tomatrix
            x += 1
        end
        result
    end

    parttwo = begin
        o2 = filternums(nums) do col
            count(==(1), col) >= count(==(0), col) ? 1 : 0
        end

        co2 = filternums(nums) do col
            count(==(0), col) <= count(==(1), col) ? 0 : 1
        end

        parse(Int, "0b$(join(o2))") * parse(Int, "0b$(join(co2))")
    end

    partone, parttwo
end

@time solve()