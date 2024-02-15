local	component = require("component")
local	event = require("event")
local	thread = require("thread")

S = {
	["RUNNING"] = 1 << 0,
	["SUSPENDED"] = 1 << 1,
	["DEAD"] = 1 << 2,
}

E = {
	["GETC_PAD"] = 1 << 0,
	["GETC_DOOR"] = 1 << 1,
}

-- [[ UTILS ]] --
local	function	getc(addr)
	local	a = component.get(addr)
	if a == nil then return nil end
	return component.proxy(a)
end

local	function	log(str)
	local	f = io.open("/home/log", "a")
	f:write(str.."\n")
	f:close()
end

-- [[ STATUS ]] --
local	function print_status()
	local	status = "unknown"

	if args.STATUS == S["RUNNING"] then
		status = "Running"
	elseif args.STATUS == S["SUSPENDED"] then
		status = "Suspended"
	elseif args.STATUS == S["DEAD"] then
		status = "Dead"
	end

	print("Status: ("..status..")")
	print("    ├─Thread (pad): "..args.THREAD_PAD:status())
	print("    ├─Thread (red): "..args.THREAD_RED:status())
	print("    └─Input: "..args.INPUT)
	if args.ERR & E["GETC_PAD"] > 0 then
		print("Error getting pad ("..args.PAD_ADDR..")")
	end
	if args.ERR & E["GETC_DOOR"] > 0 then
		print("Error getting door ("..args.DOOR_ADDR..")")
	end
end

function	status()
	args.ERR = 0

	if args.PAD == nil then set_err(E["GETC_PAD"]) end
	if args.DOOR == nil then set_err(E["GETC_DOOR"]) end

	print_status()
end

-- [[ ERROR ]] --
local	function set_err(v) args.ERR = args.ERR | v end

local	function	setup_pad()
	args.PAD.setShouldBeep(true)
	args.PAD.setVolume(0.12)

	args.PAD.setDisplay("Code", 3)

	args.PAD.setKey(1, "1", 7)
	args.PAD.setKey(2, "2", 7)
	args.PAD.setKey(3, "3", 7)
	args.PAD.setKey(4, "4", 7)
	args.PAD.setKey(5, "5", 7)
	args.PAD.setKey(6, "6", 7)
	args.PAD.setKey(7, "7", 7)
	args.PAD.setKey(8, "8", 7)
	args.PAD.setKey(9, "9", 7)
	args.PAD.setKey(10, "A", 2)
	args.PAD.setKey(11, "0", 7)
	args.PAD.setKey(12, "B", 4)

	args.PAD.setEventName("keypress_main_pad")
end

local	function	close_door()
	if args.DOOR.isOpen() then args.DOOR.toggle() end
end

local	function	open_door()
	if args.DOOR.isOpen() == false then args.DOOR.toggle() end
end

local	function	setup_door()
	close_door()
end

local	function	wrong_pass()
	args.PAD.setDisplay("Wrong", 4)
	os.sleep(0.5)
	args.PAD.setDisplay("")
	os.sleep(0.5)
	args.PAD.setDisplay("Wrong", 4)
	os.sleep(0.5)
	args.PAD.setDisplay("")
	os.sleep(0.5)
	args.PAD.setDisplay("Wrong", 4)
	os.sleep(0.5)
	args.PAD.setDisplay("")
	os.sleep(0.5)
	args.PAD.setDisplay("Code", 3)
end

local	function	check_input()
	local	input = args.INPUT
	args.INPUT = ""

	if args.PASS == input then
		open_door()
		args.PAD.setDisplay("Good", 2)
		os.sleep(3)
		args.PAD.setDisplay("Code", 3)
		return
	end
	close_door()
	wrong_pass()
end

local	function	watch_pad()
	args.STATUS = S["RUNNING"]
	while args.STATUS == S["RUNNING"] do
		local	_, _, id, key = event.pull("keypress_main_pad")
		log("KEY "..key.."("..id..") pressed")
		if id == 10 then
			check_input()
		else
			if id == 12 then
				args.INPUT = args.INPUT:sub(1, -2)
			else
				args.INPUT = args.INPUT..key
			end
			if #args.INPUT == 0 then
				args.PAD.setDisplay("Code", 3)
			else
				args.PAD.setDisplay(string.rep("*", #args.INPUT))
			end
		end
	end
end

local	function	watch_red()
	while args.STATUS == S["RUNNING"] do
		local	input = args.RED.getInput(4)
		if input > 0 then
			args.DOOR.toggle()
			os.sleep(2)
			log("RED PRESSED")
		end
		os.sleep(1)
	end
end

function	setup(mode)
	local	m = mode or "all"
	local	f = io.open("/etc/sec_pass", "r")

	args.PASS = f:read()
	f:close()
	if m == "all" then
		setup_pad()
		setup_door()
	elseif m == "pad" then
		setup_pad()
	elseif m == "door" then
		setup_door()
	end
end

local	function	status_thread()
	local	s = args.THREAD_PAD:status()
	if s == "running" then
		args.STATUS = S["RUNNING"]
	elseif s == "dead" then
		args.STATUS = S["DEAD"]
	elseif s == "suspended" then
		args.STATUS = S["SUSPENDED"]
	end
end

local	function	start_thread()
	if args.THREAD_PAD == nil then
		args.THREAD_PAD = thread.create(watch_pad)
	end
	local	status = args.THREAD_PAD:status()
	log("PAD "..status)
	if status == "dead" then
		args.THREAD_PAD = thread.create(watch_pad)
	end
	if status == "suspended" then
		args.THREAD_PAD:resume()
	end
	status_thread()

	if args.THREAD_RED == nil then
		args.THREAD_RED = thread.create(watch_red)
	end
	local	status = args.THREAD_RED:status()
	log("RED "..status)
	if status == "dead" then
		args.THREAD_RED = thread.create(watch_red)
	end
	if status == "suspended" then
		args.THREAD_RED:resume()
	end
end

function	start()
	args.STATUS = S["DEAD"]
	if args.STATUS == S["DEAD"] then
		args.INPUT = ""
		args.THREAD_PAD = nil
		args.THREAD_RED = nil
		if args.PAD == nil then args.PAD = getc(args.PAD_ADDR) end
		if args.DOOR == nil then args.DOOR = getc(args.DOOR_ADDR) end
		if args.RED == nil then args.RED = getc(args.RED_ADDR) end
		args.INPUT = ""
		setup()
	end
	start_thread()
	status()
end

function	stop()
	args.THREAD_PAD:kill()
	args.THREAD_RED:kill()
	status_thread()
end
