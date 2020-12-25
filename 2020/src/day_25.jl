function transform(subject::Int, value::Int)
    subject * value  % 20201227
end

function findloop(publickey::Int, subject::Int=7)
    i = 0
    v = 1
    while v != publickey
        v = transform(subject, v)
        i += 1
    end
    i
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    cardkey, doorkey = parse.(Int, split(strip(input), "\n"))
    v = 1
    for _ in 1:findloop(cardkey)
        v = transform(doorkey, v)
    end
    v
end

@time @show solve()
