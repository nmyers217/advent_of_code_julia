using Pkg
Pkg.add("ResumableFunctions")
using ResumableFunctions

const Grid = Array{Char, 2}

function parsegrid(str::AbstractString)::Grid
    arr = split(strip(str), "/")
    result = fill('.', (length(arr), length(arr)))
    for (y, line) in enumerate(arr)
        for (x, str) in enumerate(split(strip(line), ""))
            result[y, x] = first(str)
        end
    end
    result
end

@resumable function bigrows(grid)
    rowsize = first(size(grid))
    if rowsize < 2; error("The grid did not have enough rows.") end
    height = rowsize % 2 == 0 ? 2 : 3
    numrows = convert(Int, rowsize / height)
    for y in 1:numrows
        starty = y * height - height + 1
        endy = starty + height - 1
        @yield view(grid, starty:endy, :)
    end
end

@resumable function squares(grid)
    (_, colsize) = size(grid)
    if colsize < 2; error("The grid did not have enough columns.") end
    width = colsize % 2 == 0 ? 2 : 3
    numsquares = convert(Int, colsize / width)
    for x in 1:numsquares
        startx = x * width - width + 1
        endx = startx + width - 1
        @yield view(grid, :, startx:endx)
    end
end

@resumable function orientations(grid)
    cur = grid
    for _ in 1:4
        cur = rotr90(cur)
        for orientation in [cur, reverse(cur, dims=1)]
            @yield orientation
        end
    end
end

function printgrid(grid)
    println(join([join(row) for row in eachrow(grid)], '\n'), "\n")
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    rules::Dict{Grid, Grid} = reduce(split(strip(input), "\n"), init=Dict()) do result, line
        (left, right) = split(strip(line), " => ")
        result[parsegrid(left)] = parsegrid(right)
        result
    end

    grid::Grid = parsegrid(".#./..#/###")

    iterate() = begin
        nextgrid = []
        for rowofsquares in bigrows(grid)
            nextsquares = []

            for square in squares(rowofsquares)
                for (rule, output) in rules, orientation in orientations(square)
                    if orientation == rule
                        nextsquares = isempty(nextsquares) ? output : hcat(nextsquares, output)
                        break
                    end
                end
            end

            nextgrid = isempty(nextgrid) ? nextsquares : vcat(nextgrid, nextsquares)
        end
        grid = nextgrid
    end

    partone = begin
        for _ in 1:5 iterate() end
        count(==('#'), grid)
    end

    parttwo = begin
        for _ in 6:18 iterate() end
        count(==('#'), grid)
    end

    partone, parttwo
end

@time solve()
