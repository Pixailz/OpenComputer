local	c = require("component")
local	e = require("event")
local	m = c.modem

local	PORT = 123

m.open(PORT)

local	running = true

while running do
	local	event_type,
			addr_dst,
			addr_src,
			port,
			distance,
			data = e.pull("modem_message")

	if port == PORT then
		print("data ", data)
	end
end
