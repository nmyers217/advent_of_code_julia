function parseboard(str)
    rows = filter.(str -> str != "", split.(split(str, "\n"), " "))
    result = fill(0, (length(rows), length(rows |> first)))
    for (y, row) in enumerate(rows)
        for (x, col) in enumerate(row)
            result[y, x] = parse(Int, col)
        end
    end
    result
end

function rowsandcols(board)
    union(eachrow(board), eachcol(board))
end

function score(marked, board)
    sum(n for n in board if n ∉ marked) * last(marked)
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    nums_str, boards_str... = strip.(split(strip(input), "\n\n"))
    nums = parse.(Int, split(nums_str, ","))
    boards = parseboard.(boards_str)
    indexedboards = rowsandcols.(boards)

    findfirstbingo() = begin
        marked = []
        for n in nums
            push!(marked, n)

            for (i, sets) in enumerate(indexedboards)
                for s in sets
                    if intersect(s, marked) == s
                        return marked, boards[i]
                    end
                end
            end
        end
    end

    findallbingos() = begin
        marked, bingos = [], []
        for n in nums
            push!(marked, n)

            for (i, sets) in enumerate(indexedboards)
                if i in bingos continue end
                
                for s in sets
                    if intersect(s, marked) == s
                        push!(bingos, i)

                        if length(bingos) == length(boards)
                            return marked, boards[last(bingos)]
                        else
                            break
                        end
                    end
                end
            end
        end
    end

    score(findfirstbingo()...), score(findallbingos()...)
end

@time @show solve()