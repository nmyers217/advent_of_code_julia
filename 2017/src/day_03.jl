const Dir = CartesianIndex
const Point = CartesianIndex

function nextdir(d::Dir)::Dir
  if d === Dir(1, 0) return Dir(0, -1) end
  if d === Dir(0, -1) return Dir(-1, 0) end
  if d === Dir(-1, 0) return Dir(0, 1) end
  if d === Dir(0, 1) return Dir(1, 0) end
end

function neighbordirs()
  [
    Dir(-1, -1), Dir(0, -1), Dir(1, -1),
    Dir(-1,  0),             Dir(1,  0),
    Dir(-1,  1), Dir(0,  1), Dir(1,  1),
  ]
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    finalsquare = parse(Int, input)

    partone = begin
      curpoint, curdir = Point(0, 0), Dir(0, 1)
      coords = Dict{Point, Int}()
      for cursquare in 1:finalsquare-1
        coords[curpoint] = cursquare
        if !haskey(coords, curpoint + nextdir(curdir)) curdir = nextdir(curdir) end
        curpoint += curdir
      end
      sum(Tuple(curpoint - Point(0, 0)))
    end

    parttwo = begin
      curpoint, curdir = Point(1, 0), Dir(1, 0)
      coords = Dict{Point, Int}(Point(0, 0) => 1)
      while true
        neighbors = [get(coords, curpoint + nd, 0) for nd in neighbordirs()]
        coords[curpoint] = sum(neighbors)
        if coords[curpoint] > finalsquare break end
        if !haskey(coords, curpoint + nextdir(curdir)) curdir = nextdir(curdir) end
        curpoint += curdir
      end
      coords[curpoint]
    end

    partone, parttwo
end

@time solve()
