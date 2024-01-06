--[[ BIGINT CLASS
]]--

local	bigint = {}

-- IMPORT
	-- VANILLA
	-- CUSTOM

-- UTILS

-- mew
function	bigint.new(n)
	local	type_n = type(n)
	o = {}

	if type_n == "string" then
		o.n = n
	elseif type_n == "number" then
		o.n = tostring(n)
	else
		return nil
	end

	if o.n:sub(1, 1) == "-" then
		o.s = -1
		o.n = o.n:sub(2, o.n:len())
	else
		o.s = 1
	end

	o = setmetatable(o, bigint)
	return o
end

bigint.zero = bigint.new("0")
bigint.one = bigint.new("1")
bigint.two = bigint.new("2")

-- copy
-- function	copy(obj, seen)
-- 	-- from this gist
-- 	-- https://gist.github.com/tylerneylon/81333721109155b2d244

-- 	-- Handle non-tables and previously-seend tables.
-- 	if type(obj) ~= "table" then return obj end
-- 	if seen and seen[obj] then return seen[obj] end

-- 	-- new table; mark it as seen and copy recursively
-- 	local	s = seen or {}
-- 	local	res = {}
-- 	s[obj] = res
-- 	for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
-- 	return setmetatable(res, getmetatable(ob))
-- end

function	bigint.copy(src)
	o = {}
	o.n = src.n
	o.s = src.s

	return setmetatable(o, getmetatable(src))
end

local	function	mod_2(base)
	local	len_base = #base.n
	local	last_digit = base.n:sub(len_base, len_base) & 0xf

	if last_digit % 2 then return true else return false end
end

function	bigint.pow(base, exp, mod)
	local	R = bigint.copy(bigint.one)

	while exp > bigint.zero do
		if mod_2(exp) then
			R = (R * base) % mod
			print("R      "..R)
		end

		exp = exp / bigint.two

		print("exp    "..exp)

		if exp == bigint.zero then break end

		base = base * base
		print("base "..base)

		base = base % mod
		print("base "..base)

	end

	return R
end

-- function	bigint.pow(base, exp, mod)
-- 	local	R = bigint.copy(bigint.one)

-- 	while true do
-- 		if exp % bigint.two == bigint.one then
-- 			R = R * base % mod
-- 		end
-- 		exp = exp / bigint.two

-- 		if exp == bigint.zero then
-- 			break
-- 		end
-- 		base = base * base % mod
-- 	end

-- 	return R
-- end

-- METATABLES
local function	__is_good_bigint(A)
	if A == nil or A.n == nil then
		return false
	end
	if #A == 0 then
		return false
	end
	return true
end

-- __comp
-- Compare A over B, two bigint
-- bit 0 = A == B
-- bit 1 = A > B
local function	__comp(A, B)
	local	r = 0

	-- sign check
	if A.s == 1 and not B.s == -1 then
		return 2
	elseif B.s == 1 and not A.s == -1 then
		return 0
	end

	-- if equal
	if A.n == B.n then
		return 1
	end

	local	len_a = #A
	local	len_b = #B

	-- check for the len
	if len_a > len_b then
		return 2
	elseif len_b > len_a then
		return 0
	end

	for i = 1, #A.n do
		local	c_a = A.n:sub(i, i)
		local	c_b = B.n:sub(i, i)

		if c_a > c_b then
			if A.s == 1 then return 2 else return 0 end
		elseif c_b > c_a then
			if A.s == 1 then return 0 else return 2 end
		end
	end
	return 1
end

-- STRING
	--
function	__concat_get(title, target)
	c_type = type(target)
	if c_type == "table" then
		if not __is_good_bigint(target) then
			error("bad "..title.." for A'..'B operator")
		end
		if target.s == 1 then
			return target.n
		else
			return "-"..target.n
		end
	else
		return target
	end
end

function	_concat(A, B)
	A_str = __concat_get("A", A)
	B_str = __concat_get("B", B)

	return A_str..B_str
end -- operator A..B

	-- __len
function	_len(A)
	if A == nil or A.n == nil then
		return 0
	end

	if not A.s then
		return #A.n + 1
	end
	return #A.n
end -- operator #A

-- LOGIC

local function	_eq(A, B)
	local	r = __comp(A, B)
	return r == 1
end -- __eq A == B

local function	_lt(A, B)
	local	r = __comp(A, B)
	return r == 0
end -- __lt A < B

local function	_le(A, B)
	local	r = __comp(A, B)
	return r == 0 or r == 1
end -- __le A <= B

-- ARITHMETIC
function	_add(A, B)
	local	R = bigint.new("")
	local	r = 0
	local	C = 0
	local	b = 0
	local	c_a, c_b = bigint.copy(A), bigint.copy(B)

	while #c_a.n > #c_b.n do
		c_b.n = "0"..c_b.n
	end
	while #c_b.n > #c_a.n do
		c_a.n = "0"..c_a.n
	end

	if c_b.s == -1 then
		c_b.s = 1
		return _sub(c_a, c_b)
	end

	for i = #c_a.n, 1, -1 do

		local	n_a = c_a.n:sub(i, i) & 0xf
		local	n_b = c_b.n:sub(i, i) & 0xf

		r = (c_a.s * n_a) + n_b + C - b
		C = 0
		b = 0
		if r >= 10 then
			C = 1
			r = r - 10
		elseif r < 0 then
			r = -r
			R.s = -1
			if r >= 10 then
				B = 1
			end
		end
		R.n = r..R.n
	end

	if C == 1 then
		R.n = C..R.n
	end
	return R
end -- A + B

function	_sub(A, B)
	local	R = bigint.new("")
	local	r = 0
	local	b = 0
	local	C = 0
	local	c_a, c_b = bigint.copy(A), bigint.copy(B)

	while #c_a.n > #c_b.n do
		c_b.n = "0"..c_b.n
	end
	while #c_b.n > #c_a.n do
		c_a.n = "0"..c_a.n
	end

	if c_b.s == -1 then
		c_b.s = 1
		return _add(c_a, c_b)
	end

	for i = #c_a.n, 1, -1 do

		local	n_a = c_a.n:sub(i, i) & 0xf
		local	n_b = c_b.n:sub(i, i) & 0xf

		r = (c_a.s * n_a) - n_b - b + C
		C = 0
		b = 0
		if r < 0 then
			b = 1
			r = r + 10
		elseif r >= 10 then
			C = 1
			r = r - 10
		end
		R.n = r..R.n
	end

	if b == 1 then
		R = _sub(B, A)
		R.s = -1
	end

	-- Remove leading zeros
	R.n = R.n:gsub("^0+", "")
	-- Not all zeros
	if R.n == "" then R.n = "0" end

	return R
end -- A - B

--[[
	diagonals = [0] * (len(valueA) + len(valueB))
	for indexA, digitA in enumerate(valueA):
		for indexB, digitB in enumerate(valueB):
			value = int(digitA) * int(digitB)
			diagonals[indexA+indexB+0] += value // 10
			diagonals[indexA+indexB+1] += value %  10

	digits = []
	rest   = 0
	for value in reversed(diagonals):
		value += rest
		if value > 9:
			rest = value // 10
			digits.insert(0, value % 10)
		else:
			rest = 0
			digits.insert(0, value)

	if rest > 0:
		digits.insert(0, rest)

	if digits[0] == 0:
		del digits[0]
	return digits
]]--
function	_mul_lattice_get_matrix(c_l, c_r)
	local	matrix = {}
	local	current_value
	local	tmp_l, tmp_r

	print(#c_l)
	print(#c_r)

	for i_l = #c_l, 1, -1 do

		tmp_l = c_l.n:sub(i_l, i_l)
		for i_r = #c_r, 1, -1 do
			tmp_r = c_r.n:sub(i_r, i_r)
			current_value = tonumber(tmp_r) * tonumber(tmp_l)
			matrix[i_r + i_l + 0] = string.format("%.0f", current_value / 10)
			matrix[i_r + i_l + 1] = string.format("%.0f", current_value % 10)
		end
	end
	return matrix
end

function	_mul_lattice_add_matrix(matrix)
	local	R = ""
	local	rest = 0
	local	value = 0

	for i = #matrix, 1, -1 do
		value = tonumber(matrix[i]) + rest
		print("value "..value)
		if value > 9 then
			rest = value / 10
			R = matrix[i]..R
		else
			rest = 0
			R = matrix[i]..R
		end
	end

	if rest > 0 then
		R = tostring(rest)..R
	end
	print(R)
	return bigint.new(R)
end

function	_mul_lattice(A, B)
	local	c_l = bigint.copy(A)
	local	c_r = bigint.copy(B)

	if _eq(B, bigint.zero) then
		return bigint.copy(bigint.zero)
	end

	if _eq(B, bigint.one) then
		return bigint.copy(A)
	end

	-- if c_r.s == -1 then
	-- 	c_r.s = 1
	-- 	if c_l.s == -1 then c_l.s = 1
	-- 	else c_l.s = -1 end
	-- end

	return _mul_lattice_add_matrix(_mul_lattice_get_matrix(c_l, c_r))
end -- A * B

function	_mul(A, B)
	local	c_l = bigint.copy(A)
	local	c_r = bigint.copy(B)
	local	R = bigint.new("0")

	if _eq(B, bigint.zero) then
		return bigint.copy(bigint.zero)
	end

	if _eq(B, bigint.one) then
		return bigint.copy(A)
	end

	if #c_l.n < #c_r.n then
		c_r = bigint.copy(A)
		c_l = bigint.copy(B)
	end

	if c_r.s == -1 then
		c_r.s = 1
		if c_l.s == -1 then c_l.s = 1
		else c_l.s = -1 end
	end

	while _eq(c_r, bigint.zero) == false do
		R = _add(R, c_l)
		c_r = _sub(c_r, bigint.one)
	end

	return R
end -- A * B

function	_div(A, B)
	local	c_l = bigint.copy(A)
	local	c_r = bigint.copy(B)
	local	R = bigint.new("0")

	if _eq(B, bigint.zero) then
		error("cannot divide by zero")
	end

	if _eq(B, bigint.one) then
		return bigint.copy(A)
	end

	if c_r.s == -1 then c_r.s = 1 end
	if c_l.s == -1 then c_l.s = 1 end

	while true do
		c_l = _sub(c_l, c_r)
		if c_l.s ~= 1 then
			break
		end
		R = _add(R, bigint.one)
	end

	if not _eq(R, bigint.zero) then
		if B.s == -1 and A.s == -1 then
			R.s = 1
		elseif B.s == -1 or A.s == -1 then
			R.s = -1
		end
	end

	return R
end -- A / B

function	_mod(A, B)
	local	r_div = _div(A, B)
	local	r_mul = _mul(r_div, B)
	local	R = _sub(A, r_mul)

	return R
end -- A % B

function	_pow(A, B)
	local	c_l = copy(A)
	local	c_r = copy(B)
	local	R = copy(A)

	while _eq(c_r, bigint.one) == false do
		R = _mul(R, c_l)
		c_r = _sub(c_r, bigint.one)
	end
	return R
end -- A ^ B

-- operator overload
bigint.__add = _add	-- operator +
bigint.__sub = _sub	-- operator -
bigint.__mul = _mul_lattice	-- operator *
bigint.__div = _div	-- operator /

bigint.__mod = _mod	-- operator %
bigint.__pow = _pow	-- operator ^
-- bigint.__unm = _unm	-- operator unary -

bigint.__concat = _concat	-- operator ..
bigint.__len = _len				-- operator #

bigint.__eq = _eq	-- operator ==	(A ~= B == not A == B)
bigint.__lt = _lt	-- operator <	(A < B == not B < A)
bigint.__le = _le	-- operator <=	(A >= B == not B <= A)

return bigint
