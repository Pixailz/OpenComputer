local	c = require("component")
local	g = c.gpu
local	e = require("event")
local	s = require("serialization")
local	thread = require("thread")
local	m = c.modem
local	computer = require("computer")

local	PORT = 123

m.open(PORT)

state = {
	["red"] = 0,
	["blue"] = 3,
}

running = true

function	listen(listen_port)
	while running do
		local	event_type,
				addr_dst,
				addr_src,
				port,
				distance,
				data = e.pullMultiple("modem_message")

		if port == listen_port then
			local	ud = s.unserialize(data)
			if ud.CMD == "red" or ud.CMD == "blue" then
				state[ud.CMD] = state[ud.CMD] + 5
			else
				print("Unknown command")
			end
		end
	end
end

function	print_status()
	g.set(1, 1, "UPTIME")
	g.set(1, 2, "RED")
	g.set(1, 3, "BLUE")
	while running do
		g.set(15, 1, ""..computer.uptime())
		g.set(15, 2, ""..state["red"])
		g.set(15, 3, ""..state["blue"])
		if state["red"] > 0 then state["red"] = state["red"] - 1 end
		if state["blue"] > 0 then state["blue"] = state["blue"] - 1 end
		os.sleep(1)
	end
end

local	w, h = g.getResolution()

g.fill(1, 1, w, h, " ") -- clears the screen

local	thread_table = {
	thread.create(print_status),
	thread.create(listen, PORT),
}

thread.waitForAll(thread_table)
