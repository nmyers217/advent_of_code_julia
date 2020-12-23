const SeatLayout = Array{Char,2}

function parse_input(str::AbstractString)::SeatLayout
    rows = split(strip(str), "\n")
    result = fill('.', (length(rows), length(first(rows))))
    for (y, row) in enumerate(rows)
        for (x, c) in enumerate(split(row, ""))
            result[y, x] = c[1]
        end
    end
    result
end

function next_conway(sl::SeatLayout, view_distance::Number, tolerance::Int)::SeatLayout
    dirs = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]
    result = deepcopy(sl)

    for y in axes(sl, 1)
        for x in axes(sl, 2)
            occupied = 0

            for dir in dirs
                mag = 1
                while mag <= view_distance
                    (nx, ny) = [x, y] + (dir * mag)
                    if !(1 <= ny <= size(sl, 1) && 1 <= nx <= size(sl, 2))
                        break
                    end
                    if sl[ny, nx] == '#'
                        occupied += 1
                        break
                    elseif sl[ny, nx] == 'L'
                        break
                    else
                        mag += 1
                    end
                end
            end

            result[y, x] = if sl[y, x] == 'L' && occupied == 0
                '#'
            elseif sl[y, x] == '#' && occupied >= tolerance
                'L'
            else
                sl[y, x]
            end
        end
    end

    result
end

function evolve_conway(sl::SeatLayout, view_distance::Number, tolerance::Int)
    cur = sl
    while true
        next = next_conway(cur, view_distance, tolerance)
        if cur == next
            break
        end
        cur = next
    end
    cur
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    sl = parse_input(input)

    part_one = begin
        final_sl = evolve_conway(sl, 1, 4)
        sum([count(==('#'), row) for row in final_sl])
    end

    part_two = begin
        final_sl = evolve_conway(sl, Inf, 5)
        sum([count(==('#'), row) for row in final_sl])
    end

    part_one, part_two
end

@time solve()
