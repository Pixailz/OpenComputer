local	c = require("component")
local	m = c.modem
local	s = require("serialization")

local	u = require("utils")

local	PORT = 123

function	send_cmd(cmd)
	local	data = s.serialize({["CMD"] = cmd})

	m.broadcast(PORT, data)
end

while true do
	local	input = io.stdin:read()

	if input == "r" then
		send_cmd("red")
	elseif input == "b" then
		send_cmd("blue")
	else
		print("Unknown command")
	end
end

