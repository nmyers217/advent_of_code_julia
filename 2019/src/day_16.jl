using LinearAlgebra

function gen_pattern(base_pattern::Vector{Int}, index::Int, signal_length::Int)
    shift = 1
    pattern = Vector{Int}()
    i = 1
    cnt = shift
    for j ∈ 1:signal_length
        if cnt >= index
            cnt = 0
            i += 1
            if i > length(base_pattern)
                i = 1
            end
        end
        push!(pattern, base_pattern[i])
        cnt += 1
    end
    return pattern
end

function FFT(base_pattern::Vector{Int}, signal::Vector{Int}, phases::Int)
    signal = copy(signal)
    for p ∈ 1:phases
        for i ∈ 1:length(signal)
            signal[i] = mod(abs(dot(signal, gen_pattern(base_pattern, i, length(signal)))), 10)
        end
    end
    return signal
end

# Assuming offset >= length(signal / 2)
function FFT(base_pattern::Vector{Int}, signal::Vector{Int}, phases::Int, offset::Int)
    signal = copy(signal)
    for p ∈ 1:phases
        S = 0
        for i ∈ length(signal):-1:(offset + 1)
            S = mod(S + signal[i], 10)
            signal[i] = S
        end
    end
    return signal[(offset + 1):length(signal)]
end

function solve()
    input = read("2019/res/day_16.txt", String)

    signal = parse.(Int, split(strip(input), ""))
    base_pattern = [0, 1, 0, -1]
    phases = 100
    part_one = join(FFT(base_pattern, signal, phases)[1:8])

    repeats = 10000
    signal = repeat(signal, repeats)
    offset = parse(Int, join(signal[1:7]))
    part_two = join(FFT(base_pattern, signal, phases, offset)[1:8])

    (part_one, part_two)
end

solve()
