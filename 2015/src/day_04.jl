using Pkg
Pkg.add("MD5")
using MD5

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    n = 1
    iterateuntil(fn) = begin
        while true
            hash = bytes2hex(md5("$input$n"))
            if fn(hash) break end
            n += 1
        end
        n
    end

    iterateuntil(startswith("00000")), iterateuntil(startswith("000000"))
end

@time solve()
