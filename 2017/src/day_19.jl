function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    grid = [split(line, "") for line in split(input, "\n")]

    pos, dir, order, steps = (findfirst(==("|"), grid[1]), 1), (0, 1), [], 0
    while true
        (x, y) = pos
        if x < 1 || x > length(grid[1]) || y < 1 || y > length(grid) break end
        c = grid[y][x]
        if c == " " break end

        if lowercase(c[1]) in 'a':'z' && c ∉ order; push!(order, c) end

        dir = if c == "+"
            if dir[1] != 0
                # Switch from horizontal to vertical
                dir1, dir2 = (0, -1), (0, 1)
                (x1, y1), (x2, y2) = pos .+ dir1, pos .+ dir2
                valid = (0 < x1 <= length(grid[1])) && (0 < y1 <= length(grid))
                valid && lowercase(grid[y1][x1][1]) in ['|', 'a':'z'...] ? dir1 : dir2
            else
                # Switch from vertical to horizontal
                dir1, dir2 = (-1, 0), (1, 0)
                (x1, y1), (x2, y2) = pos .+ dir1, pos .+ dir2
                valid = (0 < x1 <= length(grid[1])) && (0 < y1 <= length(grid))
                valid && lowercase(grid[y1][x1][1]) in ['-', 'a':'z'...] ? dir1 : dir2
            end
        else
            dir
        end

        pos = pos .+ dir
        steps += 1
    end

    join(order), steps
end

@time @show solve()
