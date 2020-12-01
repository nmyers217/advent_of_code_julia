const Input = Tuple{Int,String}
struct Edges
    # The amount of the node yout will get
    output_amt::Int
    # The requirements you have to meet to get output_amt
    inputs::Vector{Input}
end
const Graph = Dict{String,Edges}

function parse_chemicals_graph(input::String)::Graph
    result = Dict{String,Edges}()

    parse_amt_and_chem(str) = begin
        (amt, chem) = split(strip(str))
        (parse(Int, amt), chem)
    end

    for line in split(strip(input), "\n")
        (inputs_str, output_str) = map(strip, split(line, "=>"))

        (out_amt, out_chem) = parse_amt_and_chem(output_str)
        inputs = map(parse_amt_and_chem, split(inputs_str, ", "))
        
        for (in_amt, in_chem) in inputs
            result[out_chem] = Edges(out_amt, inputs)
        end
    end

    result
end

function fuel_ore_cost(graph::Graph, fuel_amt::Int)
    result = 0

    leftovers::Dict{String,Int} = Dict()
    order_q::Vector{Input} = [(fuel_amt, "FUEL")]

    while !isempty(order_q)
        (order_amt, order_chem) = popfirst!(order_q)
        edges = graph[order_chem]

        if get!(leftovers, order_chem, 0) > 0
            if leftovers[order_chem] < order_amt
                order_amt -= leftovers[order_chem]
                leftovers[order_chem] = 0
            else
                leftovers[order_chem] -= order_amt
                continue
            end
        end

        transactions = max(ceil(Int, order_amt / edges.output_amt), 1)
        amt_acquired = transactions * edges.output_amt
        leftovers[order_chem] = max(amt_acquired - order_amt, 0)

        for (amt_needed, chem_needed) in edges.inputs
            final_amt = transactions * amt_needed

            if chem_needed == "ORE"
                result += final_amt
            else
                push!(order_q, (final_amt, chem_needed))
            end
        end
    end

    result
end

function solve()
    input = read("2019/res/day_14.txt", String)

    graph = parse_chemicals_graph(input)

    part_one = fuel_ore_cost(graph, 1)

    ore_supply = 1_000_000_000_000
    lower_bound = 2
    upper_bound = Inf
    while lower_bound + 1 != upper_bound
        max_fuel_guess = if upper_bound == Inf
            # Increase the lower_bound exponentially until it is too high
            # this will help us find the upper_bound ASAP
            lower_bound^2
        else
            # Get the midpoint
            floor(Int, (lower_bound + upper_bound) / 2)
        end

        ore_needed = fuel_ore_cost(graph, max_fuel_guess) 

        if ore_needed > ore_supply
            upper_bound = max_fuel_guess
        else ore_needed < ore_supply
            lower_bound = max_fuel_guess
        end
    end
    part_two = lower_bound

    part_one, part_two
end

solve()
