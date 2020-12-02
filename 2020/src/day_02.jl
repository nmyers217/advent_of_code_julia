struct Password
    min::Int
    max::Int
    char::Char
    val::String

    Password(str::AbstractString) = begin
        regex = r"(?<min>\S+)-(?<max>\S+) (?<char>\S+): (?<val>\S+)"
        (min, max, char, val) = match(regex, str).captures
        new(parse(Int, min), parse(Int, max), char[1], val)
    end
end

function isvalid_old(password::Password)
    chars = [s[1] for s in split(password.val, "")]
    matches = count(c -> c == password.char, chars)
    password.min <= matches <= password.max
end

function isvalid_new(password::Password)
    chars = [password.val[password.min], password.val[password.max]]
    count(c -> c == password.char, chars) == 1
end

function solve()
    input = strip(read("2020/res/day_02.txt", String))
    passwords = [Password(line) for line in split(input, "\n")]

    (count(isvalid_old, passwords), count(isvalid_new, passwords))
end

solve()
