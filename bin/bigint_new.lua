--- [===[ BIGINT CLASS ]===] ---
local	bigint = {}

bigint.n_len_max = 16

--- [===[ IMPORT ]===] ---
	--- [===[ VANILLA ]===] ---
	--- [===[ CUSTOM ]===] ---

--- [===[ FUNCTION ]===] ---
	--- [===[ UTILS ]===] ---
		--- [===[ CONVERTION ]===] ---
local function	table_toarray(n)
	if #n >= bigint.n_len_max then return n end

	local	diff = bigint.n_len_max - #n
	local	new_n = {}

	for i = 1, bigint.n_len_max do
		if i <= diff then
			new_n[i] = 0
		else
			new_n[i] = n[i - diff]
		end
	end
	return new_n
end

local function	number_toarray(n)
	local	tmp_n = n
	local	new_n = {}
	local	i = 1

	while tmp_n >= 0 and i < 10 do
		new_n[i] = tmp_n % 10
		i = i + 1
		tmp_n = math.floor(tmp_n / 10)
	end

	local	new_n_len = #new_n
	for i = 1, #new_n//2, 1 do
		new_n[i], new_n[#new_n - i + 1] = new_n[#new_n - i + 1], new_n[i]
	end
	return table_toarray(new_n)
end

local function	string_toarray(n)
	local	new_n = {}

	for i = 1, #n do new_n[i] = tonumber(n:sub(i, i)) end
	return table_toarray(new_n)
end


		--- [===[ CHECK ]===] ---
local function	is_good_bigint(target)
	if target == nil or target.n == nil then return false end
	if #target == 0 then return false end
	return true
end

	--- [===[ BASE ]===] ---
function	bigint.new(n, s)
	local	type_n = type(n)
	o = {}

	if type_n == "table" then
		o.n = table_toarray(n)
	elseif type_n == "number" then
		o.n = number_toarray(n)
	elseif type_n == "string" then
		o.n = string_toarray(n)
	else
		return nil
	end

	if s == -1 or s == 1 then o.s = s else return nil end

	o = setmetatable(o, bigint)
	return o
end

function	bigint.copy(src)
	o = {}
	o.n = src.n
	o.s = src.s

	return setmetatable(o, getmetatable(src))
end

	--- [===[ OPERATOR ]===] ---

		--- [===[ STRING ]===] ---
function	_tostring(target)
	if not is_good_bigint(target) then error("bad target '..' operator") end

	local	new_n = {}
	local	new_i = 1
	local	begin = false

	for i = 1, #target.n do
		if begin then
			new_n[new_i] = target.n[i]
			new_i = new_i + 1
		else
			if target.n[i] ~= 0 then
				new_n[new_i] = target.n[i]
				new_i = new_i + 1
				begin = true
			end
		end
	end
	if begin == false then
		return "0"
	else
		local	str = table.concat(new_n)
		if target.s == 1 then return str else return "-"..str end
	end
end -- operator '<<'

local function	concat_get(target)
	local	t_type = type(target)

	if t_type == "table" then
		return _tostring(target)
	elseif t_type == "string" then
		return target
	else
		error("bad target '..' operator")
	end
end

function	_concat(A, B)
	local	A_str = concat_get(A)
	local	B_str = concat_get(B)
	return A_str..B_str
end -- operator A..B

	-- __len
function	_len(A)
	if A == nil or A.n == nil then return 0 end
	if not A.s then return #A.n + 1 end
	return #A.n
end -- operator #A

		--- [===[ LOGIC ]===] ---

-- comp
-- Compare A over B, two bigint
-- bit 0 = A == B
-- bit 1 = A > B
local function	comp(A, B)
	local	r = 0

	-- sign check
	if A.s > B.s then return 2
	elseif B.s == 1 and not A.s == -1 then return 0
	end

	-- if equal
	if A.n == B.n then return 1 end

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
local function	_eq(A, B)
	local	r = comp(A, B)
	return r == 1
end -- __eq A == B

local function	_lt(A, B)
	local	r = comp(A, B)
	return r == 0
end -- __lt A < B

local function	_le(A, B)
	local	r = comp(A, B)
	return r == 0 or r == 1
end -- __le A <= B

		--- [===[ ARITHMETIC ]===] ---
function	_add(A, B)
	local	result = bigint.new(0, 1)
	local	carry = 0

	for i = bigint.n_len_max, 1, -1 do
		local	tmp = A.n[i] + B.n[i]
		if tmp >= 10 then
			carry = math.floor(tmp / 10)
			result.n[i] = tmp % 10
		else
			result.n[i] = tmp + carry
			carry = 0
		end
		-- print("i"..i.."| A "..A.n[i].."+"..B.n[i].." B = "..result.n[i])
	end
	if carry > 0 then error("overflow ...") end
	return result
end -- A + B

function	_sub(A, B)
	local	result = bigint.new(0, 1)
	local	borrow = 0

	for i = bigint.n_len_max, 1, -1 do
		local	tmp = A.n[i] - B.n[i]
		if tmp < 0 then
			borrow = 10
			result.n[i] = tmp + borrow
		else
			result.n[i] = tmp - borrow
			borrow = 0
		end
		-- print("i"..i.."| A "..A.n[i].."-"..B.n[i].." B = "..result.n[i])
	end
	if borrow > 0 then error("overflow ...") end
	return result
end -- A - B

-- function	_mul_lattice_get_matrix(c_l, c_r)
-- 	local	matrix = {}
-- 	local	current_value
-- 	local	tmp_l, tmp_r

-- 	print(#c_l)
-- 	print(#c_r)

-- 	for i_l = #c_l, 1, -1 do

-- 		tmp_l = c_l.n:sub(i_l, i_l)
-- 		for i_r = #c_r, 1, -1 do
-- 			tmp_r = c_r.n:sub(i_r, i_r)
-- 			current_value = tonumber(tmp_r) * tonumber(tmp_l)
-- 			matrix[i_r + i_l + 0] = string.format("%.0f", current_value / 10)
-- 			matrix[i_r + i_l + 1] = string.format("%.0f", current_value % 10)
-- 		end
-- 	end
-- 	return matrix
-- end

-- function	_mul_lattice_add_matrix(matrix)
-- 	local	R = ""
-- 	local	rest = 0
-- 	local	value = 0

-- 	for i = #matrix, 1, -1 do
-- 		value = tonumber(matrix[i]) + rest
-- 		print("value "..value)
-- 		if value > 9 then
-- 			rest = value / 10
-- 			R = matrix[i]..R
-- 		else
-- 			rest = 0
-- 			R = matrix[i]..R
-- 		end
-- 	end

-- 	if rest > 0 then
-- 		R = tostring(rest)..R
-- 	end
-- 	print(R)
-- 	return bigint.new(R)
-- end

-- function	_mul_lattice(A, B)
-- 	local	c_l = bigint.copy(A)
-- 	local	c_r = bigint.copy(B)

-- 	if _eq(B, bigint.zero) then
-- 		return bigint.copy(bigint.zero)
-- 	end

-- 	if _eq(B, bigint.one) then
-- 		return bigint.copy(A)
-- 	end

-- 	-- if c_r.s == -1 then
-- 	-- 	c_r.s = 1
-- 	-- 	if c_l.s == -1 then c_l.s = 1
-- 	-- 	else c_l.s = -1 end
-- 	-- end

-- 	return _mul_lattice_add_matrix(_mul_lattice_get_matrix(c_l, c_r))
-- end -- A * B

-- function	_mul(A, B)
-- 	local	R = bigint.new(0)

-- 	if _eq(B, bigint.zero) then
-- 		return bigint.copy(bigint.zero)
-- 	end

-- 	if _eq(B, bigint.one) then
-- 		return bigint.copy(A)
-- 	end

-- 	if #c_l.n < #c_r.n then
-- 		c_r = bigint.copy(A)
-- 		c_l = bigint.copy(B)
-- 	end

-- 	if c_r.s == -1 then
-- 		c_r.s = 1
-- 		if c_l.s == -1 then c_l.s = 1
-- 		else c_l.s = -1 end
-- 	end

-- 	while _eq(c_r, bigint.zero) == false do
-- 		R = _add(R, c_l)
-- 		c_r = _sub(c_r, bigint.one)
-- 	end

-- 	return R
-- end -- A * B

--- [===[ ATTRIBUTE ]===] ---

bigint.zero = bigint.new(0)
bigint.one = bigint.new(1)
bigint.two = bigint.new(2)

-- operator overload
bigint.__add = _add	-- operator +
bigint.__sub = _sub	-- operator -
-- bigint.__mul = _mul_lattice	-- operator *
-- bigint.__div = _div	-- operator /

-- bigint.__mod = _mod	-- operator %
-- bigint.__pow = _pow	-- operator ^
-- -- bigint.__unm = _unm	-- operator unary -

bigint.__tostring	= _tostring		-- operator '<<' (print function)
bigint.__concat		= _concat		-- operator ..
bigint.__len		= _len			-- operator #

-- bigint.__eq = _eq	-- operator ==	(A ~= B == not A == B)
-- bigint.__lt = _lt	-- operator <	(A < B == not B < A)
-- bigint.__le = _le	-- operator <=	(A >= B == not B <= A)

-- test zone

-- n1 = bigint.new({1, 2, 3, 4}, 1)
-- n2 = bigint.new(1234, 1)
-- n3 = bigint.new("1234", 1)

-- n1 = bigint.new({1}, 1)
-- n2 = bigint.new(2, 1)
-- n3 = bigint.new("3", 1)

-- print(n1)			-- table
-- print(n2)			-- int
-- print(n3)			-- str | '<<'
-- print(n1..n2)		-- '..'
-- print(#n1)			-- '#'

-- n1 = bigint.new({1,2,3,4}, 1)
-- n2 = bigint.new(1, 1)
-- n3 = n1 + n2
-- -- -- print(n1)
-- print(n3)

n1 = bigint.new(4, 1)
n2 = bigint.new(1, 1)
-- n5 = n1 + n2
-- n6 = n1 + n2

print(n1.." + "..n2.." = "..n1 + n2)
print(n1.." - "..n2.." = "..n1 - n2)

return bigint
