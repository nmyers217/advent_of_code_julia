using Test

struct Passport
    vals::Dict{String,String}

    Passport(str::String) = begin
        pairs = [split(p, ":") for p in split(strip(str), " ")]
        vals = Dict()
        for (k, v) in pairs
            vals[k] = v
        end
        new(vals)
    end
end

function parse_input(input::String)::Vector{Passport}
    lines = split(strip(input), "\n\n")
    entries = [join(split(line, "\n"), " ") for line in lines]
    map(Passport, entries)
end

function isvalid(passport::Passport)
    required = Set(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"])
    issubset(required, Set(keys(passport.vals)))
end

function isvalid_strict(passport::Passport)
    validators = Dict(
    "byr" => val -> 1920 <= parse(Int, val) <= 2002,
    "iyr" => val -> 2010 <= parse(Int, val) <= 2020,
    "eyr" => val -> 2020 <= parse(Int, val) <= 2030,
    "hgt" => val -> begin
        if endswith(val, "cm")
            150 <= parse(Int, replace(val, "cm" => "")) <= 193
        elseif endswith(val, "in")
            59 <= parse(Int, replace(val, "in" => "")) <= 76
        else
            false
        end
    end,
    "hcl" => val -> begin
        m = match(r"#[a-z0-9]{6}", val)
        !isnothing(m) && m.match == val
    end,
    "ecl" => val -> val in Set(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]),
    "pid" => val -> length(val) == 9,
    "cid" => val -> true
    )
    isvalid(passport) && all([validators[k](v) for (k, v) in passport.vals])
end

function solve()
    input = read("2020/res/day_04.txt", String)
    passports = parse_input(input)
    (count(isvalid, passports), count(isvalid_strict, passports))
end

function run_tests()
    test_input = """
    ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
    byr:1937 iyr:2017 cid:147 hgt:183cm

    iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
    hcl:#cfa07d byr:1929

    hcl:#ae17e1 iyr:2013
    eyr:2024
    ecl:brn pid:760753108 byr:1931
    hgt:179cm

    hcl:#cfa07d eyr:2025 pid:166559648
    iyr:2011 ecl:brn hgt:59in
    """

    passports = parse_input(test_input)
    @test count(isvalid, passports) == 2

    invalids = """
    eyr:1972 cid:100
    hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

    iyr:2019
    hcl:#602927 eyr:1967 hgt:170cm
    ecl:grn pid:012533040 byr:1946

    hcl:dab227 iyr:2012
    ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

    hgt:59cm ecl:zzz
    eyr:2038 hcl:74454a iyr:2023
    pid:3556412378 byr:2007
    """
    @test count(isvalid_strict, parse_input(invalids)) == 0

    valids = """
    pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
    hcl:#623a2f

    eyr:2029 ecl:blu cid:129 byr:1989
    iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

    hcl:#888785
    hgt:164cm byr:2001 iyr:2015 cid:88
    pid:545766238 ecl:hzl
    eyr:2022

    iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
    """
    @test count(isvalid_strict, parse_input(valids)) == 4
end

run_tests()
solve()
