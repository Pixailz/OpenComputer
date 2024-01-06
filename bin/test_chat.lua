local	serialization = require("serialization")

local	e_handler = require("event_handler")
local	server = require("server")
local	log = require("log")

log.lvl = 0
log.file = "/home/chat.log"

local	utils = require("utils")
local	rsa = require("rsa")

pub, priv = rsa.open("/etc/id_mc_rsa")

-- BEGIN
local	chat_port = 4444

server.listen(chat_port)

function	do_connected(from)
	log.info("chat: CONNECTED: received "..from)
end

-- do connection
local data = {}
data.cmd = "CONNECTED"
data.pub_key = pub

log.info("chat: CONNECTED: send")
log.print("pub_key    "..data.pub_key.."\n")

-- -- send CONNECT
server.broadcast(chat_port, data)

-- main loop

e_handler.set_waiting("modem_message", "interrupted")

while true do
	local	event_id, security_lvl, data = e_handler.pull()

	if event_id == "interrupted" or event_id == "force_interrupted" then
		log.debug("chat: "..event_id)
		break
	end
	print("sec lvl: "..security_lvl)
	print("data:    "..data)
end

server.close(chat_port)
