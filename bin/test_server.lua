local	c = require("component")
local	e = require("event")
local	s = require("serialization")
local	thread = require("thread")
local	m = c.modem

local	PORT = 123

m.open(PORT)

state = {
	["red"] = 0,
	["blue"] = 3,
}

running = true

function	listen(listen_port)
	print("listening on port "..PORT)
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
	local	i = 0
	print("printing status")
	while running do
		print("STATUS "..i)
		print("RED    "..state["red"])
		print("BLUE   "..state["blue"])
		if state["red"] > 0 then state["red"] = state["red"] - 1 end
		if state["blue"] > 0 then state["blue"] = state["blue"] - 1 end
		os.sleep(1)
		i = i + 1
	end
end

local	thread_table = {
	thread.create(print_status),
	thread.create(listen, PORT),
}

print("begin")
thread.waitForAll(thread_table)
print("end")
