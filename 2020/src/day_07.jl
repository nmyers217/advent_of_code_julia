using Test

function parse_line(line::AbstractString)
    (left, right) = split(strip(line), " contain ")
    entry = replace(left, " bags" => "")
    deps = map(split(right, ",")) do str
        rx = r"(\d+) (\S+ \S+) (\S+)"
        m = match(rx, strip(str))
        if isnothing(m)
            return nothing
        end
        (n, bag) = m.captures
        (parse(Int, n), bag)
    end
    (entry, deps)
end

function parse_input(input::AbstractString)
    result = Dict()
    for (entry, deps) in [parse_line(line) for line in split(strip(input), "\n")]
        result[entry] = Dict()
        if deps == [nothing]
            continue
        end
        for (amount, bag) in deps
            result[entry][bag] = amount
        end
    end
    result
end

function bfs(bag_graph::Dict{Any}, start::String="shiny gold")
    visited = Set()
    queue = [start]
    came_from = Dict()
    while !isempty(queue)
        target = popfirst!(queue)
        for (bag, deps) in bag_graph
            if bag ∉ visited && haskey(deps, target)
                push!(queue, bag)
                came_from[bag] = target
            end
        end
        push!(visited, target)
    end
    came_from
end

function traverse(bag_graph::Dict{Any}, start::String="shiny gold")
    queue = [(1, start)]
    sum = -1
    while !isempty(queue)
        (n, bag) = popfirst!(queue)
        sum += n
        for (next_bag, amount) in bag_graph[bag]
            push!(queue, (n * amount, next_bag))
        end
    end
    sum
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    graph = parse_input(input)
    part_one = length(keys(bfs(graph)))
    part_two = traverse(graph)
    (part_one, part_two)
end

function run_tests()
    test_input = """
    light red bags contain 1 bright white bag, 2 muted yellow bags.
    dark orange bags contain 3 bright white bags, 4 muted yellow bags.
    bright white bags contain 1 shiny gold bag.
    muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
    shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
    dark olive bags contain 3 faded blue bags, 4 dotted black bags.
    vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
    faded blue bags contain no other bags.
    dotted black bags contain no other bags.
    """
    graph = parse_input(test_input)
    @test length(keys(bfs(graph))) == 4
    @test traverse(graph) == 32
end

run_tests()
@time @show solve()
