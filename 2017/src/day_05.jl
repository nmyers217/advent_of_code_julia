function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    jumps = [parse(Int, str) for str in split(strip(input), "\n")]

    partone = begin
      jumpscopy = copy(jumps)
      ip, steps = 1, 0
      while true
        if !checkbounds(Bool, jumpscopy, ip) break end
        offset = jumpscopy[ip]
        jumpscopy[ip] += 1
        ip += offset
        steps += 1
      end
      steps
    end

    parttwo = begin
      jumpscopy = copy(jumps)
      ip, steps = 1, 0
      while true
        if !checkbounds(Bool, jumpscopy, ip) break end
        offset = jumpscopy[ip]
        jumpscopy[ip] += offset >= 3 ? -1 : 1
        ip += offset
        steps += 1
      end
      steps
    end

    partone, parttwo
end

@time solve()
