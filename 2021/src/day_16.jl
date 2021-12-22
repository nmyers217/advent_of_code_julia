function getbits(hexstring)
    bits = join([bitstring(parse(UInt8, "0x$c"))[5:end] for c in hexstring])
    [parse(Int, c) for c in bits]
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)

    bits, i = getbits(input), 1
    partone = 0

    readbits!(n) = begin
        bitstr = bits[i:i+n-1] |> join
        i += n
        parse(Int, "0b$bitstr")
    end

    parsepacket!() = begin
        if all(==(0), bits[i:end]) return nothing end

        version = readbits!(3)
        type = readbits!(3)

        partone += version

        if type == 4
            databits = []
            while true
                databits = [databits; bits[i+1:i+4]]
                if bits[i] == 0 break end
                i += 5
            end
            i += 5
            result = parse(Int, "0b$(join(databits))")
            return result
        else
            subpackets = []
            lengthtypeid = readbits!(1)

            if lengthtypeid == 0
                len = readbits!(15)
                final = i + len
                while i < final
                    push!(subpackets, parsepacket!())
                end
            else
                numpackets = readbits!(11)
                for _ in 1:numpackets
                    push!(subpackets, parsepacket!())
                end
            end

            return if type == 0
                sum(subpackets)
            elseif type == 1
                prod(subpackets)
            elseif type == 2
                minimum(subpackets)
            elseif type == 3
                maximum(subpackets)
            elseif type == 5
                subpackets[1] > subpackets[2] ? 1 : 0
            elseif type == 6
                subpackets[1] < subpackets[2] ? 1 : 0
            elseif type == 7
                subpackets[1] == subpackets[2] ? 1 : 0
            end
        end
    end

    parttwo = parsepacket!()

    partone, parttwo
end

@time @show solve()