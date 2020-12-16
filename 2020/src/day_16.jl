using Test

const FieldRules = Dict{AbstractString,Set{Int}}
const Ticket = Vector{Int}

function FieldRules(str::AbstractString)::FieldRules
    regex = r"([\s\S]+): (\d+)-(\d+) or (\d+)-(\d+)"
    d = Dict()
    for line in (split(strip(str), "\n"))
        m = match(regex, line)
        field = m.captures[1]
        (min1, max1, min2, max2) = [parse(Int, n) for n in m.captures[2:end]]
        d[field] = Set([min1:max1; min2:max2])
    end
    d
end

mutable struct Document
    rules::FieldRules
    ticket::Ticket
    others::Vector{Ticket}

    Document(str::AbstractString) = begin
        (rules, yours, nearby) = split(strip(str), "\n\n")
        rules = FieldRules(rules)
        parse_ticket(str) = [parse(Int, n) for n in split(str, ",")]
        ticket = parse_ticket(split(yours, "\n")[2])
        others = [parse_ticket(line) for line in split(nearby, "\n")[2:end]]
        new(rules, ticket, others)
    end
end

function error_rate!(d::Document)::Int
    result = 0
    deletions = []

    for (i, ticket) in enumerate(d.others)
        for n in ticket
            valid = false
            for set in values(d.rules)
                if n in set
                    valid = true
                    break
                end
            end

            if !valid
                push!(deletions, i)
                result += n
                break
            end
        end
    end

    deleteat!(d.others, deletions)
    result
end

function field_order(d::Document)::Vector{AbstractString}
    # Build a mapping of ticket column to a set of valid fields for the column
    col_to_valids::Vector{Tuple{Int,Set{AbstractString}}} = []
    for i in 1:length(d.ticket)
        col = [t[i] for t in [[d.ticket]; d.others]]
        valid_fields = [field for (field, s) in d.rules if all(n in s for n in col)]
        push!(col_to_valids, (i, Set(valid_fields)))
    end

    # Sort the mappings by the amount of valid fields for the column
    sort!(col_to_valids, by=e -> length(e[2]))

    # Process the sorted results over and over elimanting used fields as we go
    ordering::Vector{Tuple{Int,AbstractString}} = []
    eliminated::Set{AbstractString} = Set()
    fields_left::Set{AbstractString} = Set(keys(d.rules))
    while length(fields_left) > 0
        for (col, valids) in col_to_valids
            # Grab the uneliminated valid fields for this column
            not_eliminated = symdiff(eliminated, valids)

            if length(not_eliminated) != 1
                # We can't determine the correct field for this column yet
                # so we will pass it up and try again next time
                continue
            end

            # There is only one possible uneliminated field, so that must be the one
            field = first(not_eliminated)
            push!(ordering, (col, field))
            push!(eliminated, field)
        end

        # Loop again if there are fields that still need to be found
        fields_left = symdiff(eliminated, keys(d.rules))
    end

    # Sort the fields by their column ordering and return
    [e[2] for e in sort(ordering, by=first)]
end

function solve()
    input = read("2020/res/day_16.txt", String)
    d = Document(input)
    part_one = error_rate!(d)
    part_two = prod(
        d.ticket[i] for (i, f) in enumerate(field_order(d))
        if startswith(f, "departure")
    )
    part_one, part_two
end

function run_tests()
    test_input = """
    class: 1-3 or 5-7
    row: 6-11 or 33-44
    seat: 13-40 or 45-50

    your ticket:
    7,1,14

    nearby tickets:
    7,3,47
    40,4,50
    55,2,20
    38,6,12
    """
    @test error_rate!(Document(test_input)) == 71
end

run_tests()
@time solve()
