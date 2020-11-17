using Test

const input = "273025-767253"

is_candidate(n::Int) = begin
    pass = digits(n)
    ascending = issorted(pass, rev=true)
    repeated = length(sort(unique(pass))) < 6
    ascending && repeated
end

is_candidate_strict(n::Int) = begin
    pass = digits(n)
    counts = Dict()
    for d in pass
        counts[d] = haskey(counts, d) ? counts[d] + 1 : 1
    end
    is_candidate(n) && 2 in values(counts)
end

function solve()
    (min, max) = map(s -> parse(Int, s), split(input, "-"))
    part_one = count(is_candidate, min:(max - 1))
    part_two = count(is_candidate_strict, min:(max - 1))
    part_one, part_two
end

function run_tests()
    @testset "is_candidate" begin
        @test is_candidate(111111) == true
        @test is_candidate(223450) == false
        @test is_candidate(123789) == false
    end

    @testset "is_candidate_strict" begin
        @test is_candidate_strict(112233) == true
        @test is_candidate_strict(123444) == false
        @test is_candidate_strict(111122) == true
    end
end

solve()
