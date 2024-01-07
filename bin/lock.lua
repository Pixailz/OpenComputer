local	computer = require("computer")
local	term = require("term")
local	shell = require("shell")
local	component = require("component")
local	gpu = component.gpu

local	e_handler = require("event_handler")
e_handler.set_waiting("touch", "interrupted")
local	log	= require("log")
local	u = require("utils")

log.lvl = 0
log.file = "/usr/lock/lock.log"

local	id_path = "/usr/lock/auth.lst"
local	id = nil

local	users = {}

if u.exists(id_path) & 0x1 > 0 then
	for line in io.lines(id_path) do
		users[#users + 1] = line
	end
else
	users = nil
end

login_msg = "Login"
info_msg = nil
error_msg = nil
reboot_msg = "Reboot"
shutdown_msg = "Shutdown"
sep_msg = " | "

local	res_x, res_y = tonumber(os.getenv("RES_X")), tonumber(os.getenv("RES_Y"))

if res_x and res_y then
	gpu.setResolution(res_x, res_y)
end

dx, dy = gpu.getResolution()

pDateX = dx - 22
pDateY = 1

pUtilsX = 1
pUtilsY = 1

dx, dy = math.floor(dx / 2), math.floor(dy / 2)

pLoginX = dx - (#login_msg / 2)
pLoginY = dy + 2

pErrorX = dx
pErrorY = dy - 2

-- local	function	print_login_button()
-- end

local	function	table_contain(value, table)
	for i = 1, #table do
		if table[i] == value then return true end
	end
	return false
end

local	function	print_date()
	local	data = os.date("*t")

	term.setCursor(pDateX, pDateY)
	log.printc(string.format("%02d", data.day), log.c.orange)
	log.print("/")
	log.printc(string.format("%02d", data.month), log.c.orange)
	log.print("/")
	log.printc(string.format("%04d", data.year), log.c.orange)
	log.print(" ")
	if data.wday == 1 then
		log.printc("dim", log.c.red)
	elseif data.wday == 2 then
		log.printc("lun", log.c.red)
	elseif data.wday == 3 then
		log.printc("mar", log.c.red)
	elseif data.wday == 4 then
		log.printc("mer", log.c.red)
	elseif data.wday == 5 then
		log.printc("jeu", log.c.red)
	elseif data.wday == 6 then
		log.printc("ven", log.c.red)
	elseif data.wday == 7 then
		log.printc("sam", log.c.red)
	end
	log.printc(string.format(" %02d", data.hour), log.c.cyan)
	log.print(":")
	log.printc(string.format("%02d", data.min), log.c.cyan)
	log.print(":")
	log.printc(string.format("%02d", data.sec), log.c.cyan)
	log.print("\n")
end

local	function	print_utils()
	term.setCursor(pUtilsX, pUtilsY)
	log.printc(reboot_msg, log.c.white, log.c.red)
	log.print(sep_msg)
	log.printc(shutdown_msg.."\n", log.c.white, log.c.orange)
end

local	function	print_ui()
	term.clear()

	term.setCursor(pLoginX, pLoginY)
	log.printc(login_msg.."", log.c.black, log.c.green)

	print_date()
	print_utils()

	if error_msg then
		term.setCursor(pErrorX - ((7 + #error_msg) / 2), pErrorY)
		log.printc("Error", log.c.black, log.c.red)
		log.printc(": "..error_msg)
		error_msg = nil
	end

	if info_msg then
		term.setCursor(pErrorX - ((6 + #info_msg) / 2), pErrorY)
		log.printc("Info", log.c.black, log.c.cyan)
		log.printc(": "..info_msg)
		info_msg = nil
	end
end

local	function	is_in_login(x, y)
	return y == pLoginY and x <= pLoginX + #login_msg - 1 and x >= pLoginX
end

local	function	is_in_reboot(x, y)
	return y == pUtilsY and x <= pUtilsX + #reboot_msg - 1 and x >= pUtilsX
end

local	function	is_in_shutdown(x, y)
	return y == pUtilsY and x <= pUtilsX + #reboot_msg + #shutdown_msg + #sep_msg - 1 and x >= pUtilsX + #reboot_msg + #sep_msg
end

local	function	check_login(user)
	if users == nil then
		id = user
		return
	end
	if table_contain(user, users) then
		id = user
	else
		error_msg = user.." unauthorized player..."
	end
end

while not id do
	print_ui()
	local	event_id, data = e_handler.pull()

	if event_id == "force_interrupted" then
		info_msg = "CTRL+ALT+C"
	elseif event_id == "interrupted" then
		info_msg = "CTRL+C"
	elseif event_id == "touch" then
		if is_in_login(data.px, data.py) then
			check_login(data.player)
		elseif is_in_reboot(data.px, data.py) then
			computer.shutdown(true)
		elseif is_in_shutdown(data.px, data.py) then
			computer.shutdown()
		else
			info_msg = "Click on "..login_msg
		end
	end
end

term.clear()
term.setCursor(1, 1)

dofile("/etc/motd")

log.print("Successfully logged as ")
log.printc(id.."\n", log.c.orange)

os.setenv("USER", id)
