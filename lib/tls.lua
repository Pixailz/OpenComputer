--[[ SERVER CLASS

- server.listen(modem, port)

]]--

local	tls = {}

-- IMPORT

	-- VANILLA
local	component = require("component")
local	modem = component.modem

	-- CUSTOM
local	utils = require("utils")
local	rsa = require("rsa")

-- BEGIN

	-- ATTRIBUTS
tls.active_session = {}

function	tls.recv_syn_ack(to, from, port, dist, msg)
	return {
		["to"] = to,
		["from"] = from:sub(1, 8),
		["port"] = port,
		["msg"] = msg,
	}
end

function	tls.listen_syn_ack(from, port)
	local	e_h = require("event_handler")

	e_h.modem_message = tls.recv_syn_ack
	e_h.set_waiting("modem_message", "interrupted")

	local	pub, priv = rsa.open("/etc/id_mc_rsa")

	while tls.active_session[port][from].code == "" do
		local	event_id, data = e_h.pull()

		if event_id == "modem_message" then
			if data.to == utils.id and from == data.from then
				tls.active_session[port][from].code = data.msg
			end
		elseif even_id == "interrupted" or even_id == "force_interrupted" then
			log.warn("tls: listen syn ack: interrupted")
			break
		end
	end
end

function	check_session(from, port)
	if tls.active_session[port][from] and
		tls.active_session[port][from].status == "oke" then
		return true
	else
		return false
	end
end

function	tls.recv(from, port, pub_key)
	tls.active_session[port][from] = {}
	tls.active_session[port][from].status = "pending"
	tls.active_session[port][from].code = ""

	local	secret = rsa.btol("1234")
	local	c = rsa.crypt(secret, pub_key)

	-- send SYN
	modem.send(from, port, c)

	tls.listen_syn_ack(from, port, pub_key, secret)

	print(tls.active_session[port][from].code)
end

return tls
