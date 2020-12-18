using Test

"""
A custom infix multiplication operator that has the same
precedence as addition per the following link:
https://github.com/JuliaLang/julia/blob/master/src/julia-parser.scm
"""
⨥(a::Int, b::Int) = a * b

"""
A custom infix addition operator that has the same
precedence as multiplication per the following link:
https://github.com/JuliaLang/julia/blob/master/src/julia-parser.scm
"""
×(a::Int, b::Int) = a + b

function eval_expr(str::AbstractString; fix_add=false)
    expr = replace(str, "*" => "⨥")
    if fix_add
        expr = replace(expr, "+" => "×")
    end
    eval(Meta.parse(expr))
end

function solve()
    input = read("2020/res/day_18.txt", String)
    problems = split(strip(input), "\n")
    sum(eval_expr.(problems)), sum(eval_expr.(problems; fix_add=true))
end

function run_tests()
    begin
        @test eval_expr("2 * 3 + (4 * 5)") == 26
        @test eval_expr("5 + (8 * 3 + 9 + 3 * 4 * 3)") == 437 
        @test eval_expr("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") == 12240
        @test eval_expr("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 13632
    end
    begin
        @test eval_expr("1 + (2 * 3) + (4 * (5 + 6))"; fix_add=true) == 51
        @test eval_expr("2 * 3 + (4 * 5)"; fix_add=true) == 46
        @test eval_expr("5 + (8 * 3 + 9 + 3 * 4 * 3)"; fix_add=true) == 1445
        @test eval_expr("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"; fix_add=true) == 669060
        @test eval_expr("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"; fix_add=true) == 23340
    end
end

run_tests()
@time solve()