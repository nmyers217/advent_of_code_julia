const CANT_BLOCK = Set([(4, 2), (6, 2), (8, 2), (10, 2)])
const ENERGIES = Dict('A' => 1, 'B' => 10, 'C' => 100, 'D' => 1000)

mutable struct Diagram
    floor
    occupied

    Diagram(input::AbstractString) = begin
        floor, occupied = Dict(), Dict()
        for (y, line) in enumerate(split(strip(input), "\n"))
            for (x, c) in enumerate(first.(split(line, "")))
                if c in 'A':'D'
                    occupied[(x, y)] = c
                    floor[(x, y)] = c
                elseif c == '.'
                    floor[(x, y)] = c
                end
            end
        end

        new(floor, occupied)
    end
end

function getrooms(d::Diagram)
    rooms = reduce(zip('A':'D', [4, 6, 8, 10]), init=Dict()) do rooms, (c, x)
        rooms[c] = []
        for (px, py) in keys(d.floor)
            if py > 2 && px == x push!(rooms[c], (px, py)) end
        end
        sort!(rooms[c])
        rooms
    end
end

function bfs(d::Diagram, point)
    queue = [(0, point)]
    seen = Dict(point => 0)
    while !isempty(queue)
        (moves, cur) = popfirst!(queue)

        for dir in [(-1, 0), (1, 0), (0, -1), (0, 1)]
            neighbor = cur .+ dir

            if haskey(seen, neighbor) continue end
            if haskey(d.floor, neighbor) && !haskey(d.occupied, neighbor)
                push!(queue, (moves + 1, neighbor))
                seen[neighbor] = moves + 1
            end
        end
    end
    seen
end

function getvalidmoves(d::Diagram, rooms)
    result = []
    for from in keys(d.occupied)
        amphipod = d.occupied[from]
        room = rooms[amphipod]
        isinroom = from[2] > 2

        if from == room[end] ||
            (from in room && all(point -> get(d.occupied, point, 'Z') == amphipod, room))
            # Don't move this amphipod anywhere because his room is in a good state
            continue
        end

        reachable = bfs(d, from)
        for (to, steps) in reachable
            # Can't move to a point that blocks a room
            if to in CANT_BLOCK continue end

            if to == room[end]
                # The bottom of his room is reachable so go straight there
                push!(result, (reachable[room[end]], from, room[end]))
            end

            if from != room[end] && to in room[1:end-1]
                # The top of his room is reachable and the bottom has the right amphipod in it
                room_i = [i for i in eachindex(room) if room[i] == to] |> first
                
                isgood = true
                for point in room[room_i+1:end]
                    if get(d.occupied, point, 'Z') != amphipod
                        isgood = false
                        break
                    end
                end

                if isgood
                    push!(result, (reachable[room[room_i]], from, room[room_i]))
                end
            end

            if isinroom && to[2] == 2
                # Can only move into the hall from a room
                push!(result, (reachable[to], from, to))
            end
        end
    end

    filter(el -> el[1] > 0, result)
end

function iscomplete(d::Diagram, rooms)
    all(rooms) do (amphipod, room)
        all(point -> haskey(d.occupied, point) && d.occupied[point] == amphipod, room)
    end
end

function render(d::Diagram, rooms)
    template = """
#############
#...........#
###.#.#.#.###
  #.#.#.#.#
  #########
    """
    biggertemplate = """
#############
#...........#
###.#.#.#.###
  #.#.#.#.#
  #.#.#.#.#
  #.#.#.#.#
  #########
    """
    t = (rooms |> values |> first |> length) == 2 ? template : biggertemplate
    arr = [first.(split(line, "")) for line in split(strip(t), "\n")]
    for ((x, y), c) in d.occupied
        arr[y][x] = c
    end
    for line in arr
        println(join(line))
    end
end

function reallydumbbruteforcedfs(d::Diagram, rooms)
    # NOTE: this just takes way too long on part 2 and i should have solved backwards from bottom to top with memoization instead
    stack = [(0, d)]
    seen = Dict(d.occupied => 0)
    result = typemax(Int)

    while !isempty(stack)
        (energy, d) = pop!(stack)

        if energy > result
            # Prune this part of the tree because it can't possibly produce the result
            continue
        end

        # println("Energy: $energy")
        # render(d, rooms)
        # readline()

        if iscomplete(d, rooms)
            println("SOLUTION Found in $energy energy")
            render(d, rooms)
            # readline()
            result = min(result, energy)
            continue
        end

        for (steps, from, to) in getvalidmoves(d, rooms)
            next = deepcopy(d)
            amphipod = next.occupied[from]
            next.occupied[to] = amphipod
            delete!(next.occupied, from)

            energyneeded = energy + ENERGIES[amphipod] * steps

            if energyneeded < get(seen, next.occupied, typemax(Int))
                push!(stack, (energyneeded, next))
                seen[next.occupied] = energyneeded
            end
        end
    end
    result
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    partone = begin
        initial = Diagram(input)
        rooms = getrooms(initial)
        reallydumbbruteforcedfs(initial, rooms)
    end

    parttwo = begin
        lines = split(strip(input), "\n")
        extralines = ["  #D#C#B#A#  ", "  #D#B#A#C#  "]
        lines = [lines[1:3]; extralines; lines[4:end]]
        input = join(lines, "\n")
        initial = Diagram(input)
        rooms = getrooms(initial)
        reallydumbbruteforcedfs(initial, rooms)
    end

    partone, parttwo
end

@time @show solve()
