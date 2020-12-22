mutable struct Game
    round::Int
    players::Vector{Vector{Int}}
    past_rounds::Set{Vector{Vector{Int}}}

    Game(players::Vector{Vector{Int}}) = new(0, deepcopy(players), Set())
    Game(str::AbstractString) = begin
        players = map(split(strip(str), "\n\n")) do s
            parse.(Int, split(s, "\n")[2:end])
        end
        new(0, players, Set())
    end
end

function play!(g::Game)::Game
    while !any(isempty, g.players)
        g.round += 1
        (p1, p2) = popfirst!.(g.players)
        winner = p1 > p2 ? g.players[1] : g.players[2]
        append!(winner, p1 > p2 ? [p1, p2] : [p2, p1])
    end
    g
end

function play_recurse!(g::Game)::Int
    while true
        if isempty(g.players[1])
            return 2
        elseif isempty(g.players[2]) || g.players in g.past_rounds
            return 1
        end

        g.round += 1
        push!(g.past_rounds, deepcopy(g.players))
        (p1, p2) = popfirst!.(g.players)

        if length(g.players[1]) >= p1 && length(g.players[2]) >= p2
            winner = play_recurse!(Game([g.players[1][1:p1], g.players[2][1:p2]]))
            append!(g.players[winner], winner == 1 ? [p1, p2] : [p2, p1])
        else
            winner = p1 > p2 ? g.players[1] : g.players[2]
            append!(winner, p1 > p2 ? [p1, p2] : [p2, p1])
        end
    end
end

function score(g::Game, winner=-1)
    winner = if winner == -1
        first(p for p in g.players if !isempty(p))
    else
        g.players[winner]
    end
    sum(n * i for (n, i) in zip(winner, length(winner):-1:1))
end

function solve()
    input = read("2020/res/day_22.txt", String)
    part_one = input |> Game |> play! |> score
    part_two = begin
        g = Game(input)
        winner = play_recurse!(g)
        score(g, winner)
    end
    part_one, part_two
end

@time solve()