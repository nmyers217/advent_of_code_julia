function chars(str)
    first.(split(str, ""))
end

function decode(str, mapping)
    sevensegnums = Dict(
        Set(['a', 'b', 'c', 'e', 'f', 'g']) => 0,
        Set(['c', 'f']) => 1,
        Set(['a', 'c', 'd', 'e', 'g']) => 2,
        Set(['a', 'c', 'd', 'f', 'g']) => 3,
        Set(['b', 'd', 'c', 'f']) => 4,
        Set(['a', 'b', 'd', 'f', 'g']) => 5,
        Set(['a', 'b', 'd', 'e', 'f', 'g']) => 6,
        Set(['a', 'c', 'f']) => 7,
        Set(['a', 'b', 'c', 'd', 'e', 'f', 'g']) => 8,
        Set(['a', 'b', 'c', 'd', 'f', 'g']) => 9,
    )
    segments = Set([mapping[c] for c in chars(str)])
    sevensegnums[segments]
end

function decodenote(note)
    left, right = note
    mapping = Dict()

    (one, four, seven, eight) = map([2, 4, 3, 7]) do n
        chars(filter(str -> length(str) == n, left) |> first)
    end

    # The top segment is in seven but not one
    mapping[symdiff(seven, one) |> first] = 'a'

    # Zero, Six, and Nine all use 6 segments
    zerosixornines = chars.(filter(str -> length(str) == 6, left))

    # Six is the only of the three that doesn't have one's segments as a subset
    six = filter(cs -> !issubset(one, cs), zerosixornines) |> first
    for c in one
        mapping[c] = c ∉ six ? 'c' : 'f'
    end

    # Zero is the only one that doesn't have the left 2 segments of four as a subset
    zero = filter(cs -> !issubset(symdiff(one, four), cs), zerosixornines) |> first
    for c in symdiff(one, four)
        mapping[c] = c ∉ zero ? 'd' : 'b'
    end

    # The remaining of the three is nine
    nine = symdiff([zero, six], zerosixornines) |> first

    # The bottom two segments can be derived now
    mapping[symdiff(eight, nine) |> first] = 'e'
    mapping[symdiff(keys(mapping), ['a', 'b', 'c', 'd', 'e', 'f', 'g']) |> first] = 'g'

    sum([decode(str, mapping) for str in right] .* [1000, 100, 10, 1])
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    notes = map(eachmatch(r"(.+) \| (.+)", input)) do m
        (leftstr, rightstr) = m.captures
        (split(leftstr, " "), split(rightstr, " "))
    end

    partone = begin
        segmentsused = Dict(1 => 2, 4 => 4, 7 => 3, 8 => 7)
        numuniques(arr) = count(str -> length(str) in values(segmentsused), arr)
        sum(numuniques.([note[2] for note in notes]))
    end

    parttwo = sum(decodenote.(notes))

    partone, parttwo
end

@time @show solve()