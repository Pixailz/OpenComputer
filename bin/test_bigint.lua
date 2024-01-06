local	bigint = require("bigint")

-- n1 = bigint.new("100000000000000000000000000000000000")
-- n2 = bigint.new("200000000000000000000000000000000001")
n1 = bigint.new("20")
n2 = bigint.new("10")

print(n1.." * "..n2.." = ")

n3 = n1 * n2

print(n3.n)

-- KEY_EXPOSANT = bigint.new("65537")
-- m = bigint.new("280284578885")
-- n = bigint.new("584339716531")
-- d = bigint.new("47326960961")

-- print("c "..(bigint.pow(m, KEY_EXPOSANT, n)))
