using Test

calc_fuel(mass) = floor(Int, mass / 3) - 2

calc_fuel_recur(mass) = begin
    fuel = calc_fuel(mass)
    fuel > 0 ? fuel + calc_fuel_recur(fuel) : 0
end

function solve()
    open("res/day_01.txt") do input_file
        total_fuel = 0
        total_fuel_recur = 0

        for line in eachline(input_file)
            mass = parse(Int, line)
            total_fuel += calc_fuel(mass)
            total_fuel_recur += calc_fuel_recur(mass)
        end

        return total_fuel, total_fuel_recur
    end
end

function run_tests()
    @testset "calc_fuel" begin
        @test calc_fuel(12) == 2
        @test calc_fuel(14) == 2
        @test calc_fuel(1969) == 654
        @test calc_fuel(100756) == 33583
    end

    @testset "calc_fuel_recur" begin
        @test calc_fuel_recur(14) == 2
        @test calc_fuel_recur(1969) == 966
        @test calc_fuel_recur(100756) == 50346
    end
end

solve()
