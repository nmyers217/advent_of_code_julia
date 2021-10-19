mutable struct Particle
    pos
    vel
    acc
    Particle(str::AbstractString) = begin
        m = match(r"p=<(.+)>, v=<(.+)>, a=<(.+)>", str)
        if isnothing(m) error("Could not parse: $str") end
        (p, v, a) = map(m.captures) do str
            [parse(Int, n) for n in split(strip(str), ",")]
        end
        new(p, v, a)
    end
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    manhattan(vec) = sum(abs.(vec))
    manhattan(p::Particle) = manhattan(p.pos)
    tick!(p::Particle) = begin
        p.vel .+= p.acc
        p.pos .+= p.vel
    end

    partone = begin
        particles = Particle.(split(strip(input), "\n"))
        for _ in 1:1000, p in particles
            tick!(p)
        end
        (_, i) = findmin(manhattan.(particles))
        i - 1
    end

    parttwo = begin
        particles = Particle.(split(strip(input), "\n"))
        for _ in 1:1000
            positions = Dict()
            for p in particles
                tick!(p)
                push!(get!(positions, p.pos, []), p)
            end
            particles = vcat([arr for arr in values(positions) if length(arr) == 1]...)
        end
        length(particles)
    end

    partone, parttwo
end

@time solve()
