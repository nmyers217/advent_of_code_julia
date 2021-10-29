function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    digits(str) = first.(split(str, ""))

    iterate(arr) = begin
        if isempty(arr) return arr end
        if length(arr) == 1 return [arr[1], arr[1]] end

        result, i = [], 1
        while i <= length(arr)
            j = i
            while arr[i] == arr[j]
                j += 1
                if j > length(arr); break end
            end

            cnt = j - i
            push!(result, digits("$cnt$(arr[i])")...)
            i = j
        end
        result
    end

    result = digits(input)

    partone = begin
        for _ in 1:40; result = iterate(result) end
        length(result)
    end

    parttwo = begin
        for _ in 41:50; result = iterate(result) end
        length(result)
    end

    partone, parttwo
end

@time solve()
