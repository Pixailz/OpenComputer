--[[ SERVER CLASS

- server.listen(modem, port)

]]--

local server = {}

-- IMPORT

	-- VANILLA
local	event = require("event")
local	component = require("component")
local	modem = nil
if component.isAvailable("modem") then modem = component.modem end

local	data = nil
if component.isAvailable("data") then data = component.data end

local	serialization = require("serialization")

	-- CUSTOM
local	log = require("log")
local	utils = require("utils")

-- BEGIN
	-- ATTRIBUTS
server.listen_retry = 5

	-- METHODS
function	server.listen(port)
	local	retry = 0
	if modem.isOpen(port) then
		log.warn("server: listen: port already opened, closing it")
		modem.close(port)
	end

	for i = 1, server.listen_retry do
		modem.open(port)
		if i == server.listen_retry then
			log.fail("server: list: failed to open, exceeding retrying of "..retry)
		elseif not modem.isOpen(port) then
			log.warn("server: list: failed to open, retrying ("..retry..")")
		else
			break
		end
		os.sleep(1)
	end
	log.pass("server: Listening on 0.0.0.0 "..port)
	tls.active_session[port] = {}
end

function	server.close(port)
	modem.close(port)
	log.info("server: Stop Listening on 0.0.0.0 "..port)
end

-- function	server.dns_get_record(addr, port)
-- 	if #addr > 8 then
-- 		addr = addr:sub(1, 8)
-- 	end

-- 	local	path = server.dns_root_path.."/"..addr.."/"..port

-- 	if utils.exists(path) & 0x1 < 0 then return nil end

-- 	pub = rsa.open(path)
-- 	return pub
-- end

-- function	server.dns_set_record(addr, port, pub)
-- 	local	addr = addr:sub(1, 8)

-- 	if not utils.mkdir(server.dns_root_path.."/"..addr) then
-- 		log.error("failed creating "..server.dns_root_path.."/"..addr)
-- 	end

-- 	local	fd = io.open(server.dns_root_path.."/"..addr.."/"..port, "w")
-- 	local	retv = fd:write(rsa.ltob(pub))
-- 	fd:close()
-- 	return (retv)
-- end

-- --[[
-- 	SECURITY LVL
-- 	0. dns record found and host has successfully decrypted AES key
-- *	1. dns record not found and data contain pub_key, registring
-- *	2. dns record not found data doesn't contain pub_key
-- 	3. dns record found BUT tls has failed
-- ]]--
-- function	server.recv(to, from, port, dist, data)
-- 	local	record = server.dns_get_record(from, port)
-- 	local	retv = {
-- 		["to"] = to, ["from"] = from, ["port"] = port, ["dist"] = dist,
-- 		["security_lvl"] = 0,
-- 		["udata"] = serialization.unserialize(data),
-- 	}

-- 	if not record then
-- 		if not retv.udata.pub_key then
-- 			retv.security_lvl = 2
-- 			return retv
-- 		else
-- 			server.dns_set_record(from, port, retv.udata.pub_key)
-- 			retv.security_lvl = 1
-- 			return retv
-- 		end
-- 	end
-- 	return retv
-- 	-- 	-- if tls.authenticate(from, port, record) then
-- 	-- 	-- 	return 0, unserialized
-- 	-- 	-- else
-- 	-- 		retv.security_lvl = 3
-- 	-- 		return retv
-- 	-- 	-- end
-- 	-- end
-- 	-- dns
-- end

function	server.send(to, port, data)
	data.key = rsa.open(utils.id_rsa)

	modem.send(to, port, serialization.serialize(data))
end

function	server.broadcast(port, data)
	data.key = rsa.open(utils.id_rsa)

	modem.broadcast(port, serialization.serialize(data))
end

return server
