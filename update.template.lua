--- INCLUDE
local	shell = require("shell")
local	fs = require("filesystem")
local	computer = require("computer")
local	internet= require("internet")

--- CONFIG

--- wget -f http://IP:PORT/update.lua /bin/update.lua
local	IP = ""
local	PORT = ""
local	BASE_LINK = "http://"..IP..":"..PORT


local	DO_LIB = true
local	DO_BIN = true
local	DO_CONF = true
local	DO_ETC = false
local	DO_SERVICE = false
local	DO_EXTRA = false

local	DIR_BASE = "/usr"
local	DIR_HOME ="/home"

local	DIR_TAR_LIB = DIR_BASE.."/lib"
local	DIR_SER_LIB = "lib"

local	DIR_TAR_CONF = DIR_HOME
local	DIR_SER_CONF = "config"

local	DIR_TAR_BIN = DIR_BASE.."/bin"
local	DIR_SER_BIN = "bin"

local	DIR_TAR_ETC = DIR_BASE.."/etc"
local	DIR_SER_ETC = "etc"

local	DIR_TAR_SERVICE = "/etc/rc.d/default"
local	DIR_SER_SERVICE = "rc.d"

--- UTLS
function	wget(link, dst, base)
	local	base = base or BASE_LINK
	local	dst = dst or ""
	local	full_link = base.."/"..link

	local	retv, resp = pcall(internet.request, full_link)

	if not retv then
		error("HTTP request failed")
	end

	local	file_str = ""

	retv = pcall(function()
		for chunk in resp do file_str = file_str..chunk end
	end)

	if not retv then error("Downloading "..full_link.." failed.") end

	print(full_link.." -> "..dst)

	local	file_fd = fs.open(dst, "w")
	if not file_fd then error("opening file") end

	file_fd:write(file_str)
	file_fd:close()
end

function	mkdir(path)
	if fs.isDirectory(path) then return end

	if fs.exists(path) then fs.remove(path) end

	fs.makeDirectory(path)
end

--- LIB
function wget_lib(id)
	wget(DIR_SER_LIB.."/"..id, DIR_TAR_LIB.."/"..id)
end

function	update_lib()
	if DO_LIB == false then return end

	mkdir(DIR_TAR_LIB)

	print("Downloading lib")

	--- 0x00
	wget_lib("periph.lua")
	wget_lib("log.lua")
	wget_lib("bigint.lua")
	wget_lib("vgpu.lua")

	--- 0x01
	wget_lib("periph-im.lua")
	wget_lib("utils.lua")
	wget_lib("rsa.lua")

	--- 0x02
	wget_lib("event_handler.lua")
	wget_lib("tls.lua")

	--- 0x03
	wget_lib("server.lua")

end

--- BIN
function wget_bin(id)
	wget(DIR_SER_BIN.."/"..id, DIR_TAR_BIN.."/"..id)
end

function	update_bin()
	if DO_BIN == false then return end
	mkdir(DIR_TAR_BIN)

	print("Downloading bin")
	wget_bin("lock.lua")

	wget_bin("station.lua")
	wget_bin("station_display.lua")
	wget_bin("pong.lua")

	wget_bin("test_print.lua")
	wget_bin("test_rsa.lua")
	wget_bin("test_rsa.priv")
	wget_bin("test_rsa.pub")
	wget_bin("test_node.lua")
	wget_bin("test_server.lua")
	wget_bin("test_client.lua")
	wget_bin("test_chat.lua")
	wget_bin("test_vgpu.lua")
	wget_bin("test_bigint.lua")
	wget_bin("test_tls.a.lua")
	wget_bin("test_tls.b.lua")
	wget_bin("test_zirnox.lua")
	wget_bin("test_pong.lua")
end

--- CONF
function wget_conf(id)
	wget(DIR_SER_CONF.."/"..id, DIR_TAR_CONF.."/"..id)
end

function	update_conf()
	if DO_CONF == false then return end

	mkdir(DIR_TAR_CONF)

	print("Downloading config")

	wget_conf(".shrc")
	wget(DIR_SER_CONF.."/motd", "/etc/motd")
	wget(DIR_SER_CONF.."/profile.lua", "/etc/profile.lua")
end

--- ETC
function wget_etc(id)
	wget(DIR_SER_ETC.."/"..id, DIR_TAR_ETC.."/"..id)
end

function	update_etc()
	if DO_ETC == false then return end

	mkdir(DIR_TAR_ETC)

	print("Downloading etc")

	-- wget_etc("template_station.lua")
end

--- SERVICE
function wget_service(id)
	wget(DIR_SER_SERVICE.."/"..id, DIR_TAR_SERVICE.."/"..id)
end

function	update_service()
	if DO_SERVICE == false then return end
	mkdir(DIR_TAR_SERVICE)

	print("Downloading Service")

	wget(DIR_SER_SERVICE.."/rc.cfg", "/etc/rc.cfg")
	wget_service("redgate.lua")
	wget_service("security.lua")
end

--- EXTRA

function	update_extra()
	if DO_EXTRA == false then return end

	wget("NIDE.lua", "/bin/nide", "https://raw.githubusercontent.com/nizarlj/NIDE/main")
end

--- UPDATE
function	update_script()
	print("Updating this script, relaunch script after update to make effect.")
	wget("update.lua", "/bin/update.lua")
	print("Update done")
end

--- HELP
function	help()
	print([==[
Usage: update [--help|-h] [--update|-u] [-r|--reboot] [PART..PARTN]

    -h  --help      display this help message
    -u  --update    update this script
    -r  --reboot    reboot the computer at the end

    PART            (lib bin conf etc service)
                    You can specify the part you wan't to update, for example
                    you can just update the lib part or the bin part or the 2.
                    If not provided all part is updated

    Note
                    After an update of the lib part a reboot is required, the
                    reboot flag is usefull in this case

Version: 0.0.1-alpha, by Pixailz]==])
end

--- INSTALL
local	function	update_all()
	update_lib()
	update_bin()
	update_conf()
	update_etc()
	update_service()
	update_extra()
end

local	function	update()
	for _, p in ipairs(args) do
		if p == "lib" then
			update_lib()
		elseif p == "bin" then
			update_bin()
		elseif p == "conf" then
			update_conf()
		elseif p == "etc" then
			update_etc()
		elseif p == "service" then
			update_service()
		elseif p == "service" then
			update_extra()
		elseif p == "all" then
			update_all()
		else
			print("Unknown part: "..p)
		end
	end
end

--- PARSING
local	opt = {}
opts = {}

---@param l: string = long name / name of the opt
---@param s: string = short name of the opt
---@param r: any = if present remove the opt
---@return boolean = check if an opt provided
function opt.present(l, s, r)
	if opts[l] then
		if r then opts[l] = nil end return true
	elseif opts[s] then
		if r then opts[s] = nil end return true
	end
	return false
end

---@return nil
--- parse the args and execute according to the help
--- Note: opt are arguments with 2 dashes, like '--help' is an opt and 'help' is
--- an argument
local function parsing()
	local	nb_p = 0
	local	should_exit = false

	--- Flags
	if opt.present("r", "reboot", true) then REBOOTING = true end

	--- exiting function <3
	if opt.present("h", "help") then help() should_exit = true end
	if opt.present("u", "update") then update_script() should_exit = true end

	if should_exit then
		if REBOOTING == true then computer.shutdown(true)
		else os.exit(0) end
	end
end

--- MAIN
mkdir(DIR_BASE)

args, opts = shell.parse(...)
REBOOTING = false

parsing()

if #args > 0 then
	update(args)
else
	update_all()
end

if REBOOTING then computer.shutdown(true) end
