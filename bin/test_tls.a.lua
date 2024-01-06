-- HEADER
local	component = require("component")
local	modem = component.modem

local	e_handler = require("event_handler")
local	server = require("server")
local	tls = require("tls")
local	dns = require("dns")
local	log = require("log")
local	utils = require("utils")
local	rsa = require("rsa")

--[[
	- Where
		- m is a 16 bit AES key
		- t is a CRYPTED message with m

		- n is the Public Key
		- d is the Secret Key

		- c_1 is m CRYPTED with n of B
		- c_2 is m CRYPTED with n of A

	SYN = 0x1
	SYN/ACK = 0x2
	ACK/SYN = 0x3

	1. SYN		A BROADCAST
		{ cmd: 0x1, msg: c_1 }

	2. SYN/ACK
		1. B RECV c_1
		2. B DECRYPT c_1 to have m
		3. B CRYPT m with n of A, to have c_2
		4. B send c_2 TO A
		{ cmd: 0x2, msg: c_2 }

	3. ACK/SYN
		1. A RECV c_2
		2. A DECRYPT c_2 to have m
		3. A CRYPT "OKE" with m to have t and SEND it to B
		{ cmd: 0x3, msg: t }

	4. SYN
		1. B RECV t
		2. B CRYPT a "OKE" with m to to have t_2
		{ cmd: 0x1, msg: t }

]]--

-- BEGIN

TLS_PORT = 443
TLS_SECRET = rsa.btol("ABCD")

e_handler.set_waiting("modem_message", "interrupted")
log.lvl = 0
log.file = "/home/tls.log"

n_a, d_a = rsa.open("/etc/id_mc_rsa")
print("A: n: "..string.format("%#010x", n_a))
print("A: d: "..string.format("%#010x", d_a))

print("A: m: "..string.format("%#010x", TLS_SECRET))
print("A: m: "..rsa.ltob(TLS_SECRET))

server.listen(TLS_PORT)

local	n_b = dns.get_record("786bd653", 443)
print("A: n_b: "..n_b)

function	send_syn()
	local	c_1 = rsa.crypt(TLS_SECRET, n_b)
	local	packet = {
		["cmd"] = 0x1,
		["msg"] = c_1,
	}
	server.broadcast(TLS_PORT, packet)
end

e_handler.set_waiting("modem_message", "interrupted")

send_syn()

function	process_ack_syn(udata)
	local	m = rsa.decrypt(tonumber(udata.msg), d_a, n_a)
	TLS_SECRET_RECV = m
	print("A: m: "..string.format("%#010x", TLS_SECRET_RECV))
	print("A: m: "..rsa.ltob(TLS_SECRET_RECV))
end

function	process_cmd(udata)
	if udata.cmd == 0x2 then
		process_ack_syn(udata)
	else
		log.warn("unknown cmd")
	end
end

while true do
	local	event_id, data = e_handler.pull()
	if event_id == "interrupted" or event_id == "force_interrupted" then
		log.debug("tls: "..event_id)
		break
	end
	-- print("udata.cmd:  "..data.udata.cmd)
	-- print("udata.msg:  "..data.udata.msg)
	-- print("udata.key:  "..data.udata.key)
	if data.udata and data.udata.cmd then
		process_cmd(data.udata)
	end
end

server.close(TLS_PORT)
