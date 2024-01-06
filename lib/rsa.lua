--[[ RSA CLASS

- rsa.exp
- rsa.key_len

- rsa.pow(base, exp, mod)
- rsa.open(file)

]]--

local	rsa = {}

-- IMPORT

	-- VANILLA
local	fs = require("filesystem")
	-- CUSTOM
local	log = require("log")

-- BEGIN

	-- ATTRIBUTS
rsa.exp = 65537
rsa.key_len = 16

	-- METHODS
		-- modulo pow algo
function	rsa.pow(base, exp, mod)
	local	result = 1;

	while exp > 0 do
		if (exp & 1) > 0 then
			result = (result * base) % mod
		end
		exp = exp >> 1
		base = (base * base) % mod
	end
	return result
end

-- open rsa key file, could be .pub or private key
function	rsa.open(file)
	if not fs.exists(file) then
		log.fail("rsa.open: "..file.." doesn't exist")
		return
	end

	local f = io.open(file, "rb")
	if not f then
		log.fail("rsa.open: "..file.." open failed")
		return
	end

	local	pub_key = 0
	local	priv_key = 0
	local	i = 0

	while i < rsa.key_len / 4 do
		local c = f:read(1)
		if c == nil then break end
		pub_key = pub_key + (string.byte(c) << ((3 - i) * 8))
		i = i + 1
	end

	i = 0
	while i < rsa.key_len / 4 do
		local c = f:read(1)
		if c == nil then break end
		priv_key = priv_key + (string.byte(c) << ((3 - i) * 8))
		i = i + 1
	end

	f:close()
	return pub_key, priv_key
end

function	rsa.crypt(msg, pub)
	if type(msg) ~= "number" then
		log.warn("rsa: crypt: "..msg.." not a number")
	end

	return rsa.pow(msg, rsa.exp, pub)
end

function	rsa.decrypt(crypted, priv, pub)
	if type(crypted) ~= "number" then
		log.warn("rsa: decrypt: "..crypted.." not a number")
	end

	return rsa.pow(crypted, priv, pub)
end

function	rsa.btol(text)
	local number = 0

	if text == nil then
		return 0
	end

	for i = 1, #text do
		number = (number << 8) + string.byte(text:sub(i, i))
	end
	return number
end

function	rsa.ltob(number)
	local text = ""

	while number > 0 do
		text = string.char(number & 0xff)..text
		number = number >> 8
	end
	return text
end

return rsa
