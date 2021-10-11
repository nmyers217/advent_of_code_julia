function validphrase(phrase)
  seen = Set()
  for word in split(phrase, " ")
    if word in seen return false end
    push!(seen, word)
  end
  true
end

function morevalidphrase(phrase)
  seen = Set()
  for word in split(phrase, " ")
    chars = Set(split(word, ""))
    if chars in seen return false end
    push!(seen, chars)
  end
  true
end

function solve()
    input = read(joinpath(@__DIR__, "../res", replace(basename(@__FILE__), "jl" => "txt")), String)
    phrases = split(strip(input), "\n")
    count(validphrase, phrases), count(morevalidphrase, phrases)
end

@time solve()
