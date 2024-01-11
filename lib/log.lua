--[[ LOG CLASS

- log.sep
	separator between title and str
- mode
	bit set:
	- 01 out
	- 10 file

- log.print(str, mode)
- log.printc(str, foreground, background, mode)

]]--

local	log = {}

-- IMPORT
	-- VANILLA
local	component = require("component")
local	gpu = component.gpu
local	computer = require("computer")
local	colors = require("colors")
local	term = require("term")
local	fs = require("filesystem")

	-- CUSTOM

-- BEGIN

	-- ATTRIBUTS
log.sep = ": "
log.lvl = tonumber(os.getenv("LOG_LVL")) or 0
log.path = ""
log.fd = nil

log.c = {}
log.c.white = 0xFFFFFF
log.c.orange = 0xFF8700
log.c.magenta = 0xFD5FF1
log.c.lblue = 0x96CBFE
log.c.yellow = 0xFFD242
log.c.lime = 0x94FA36
log.c.pink = 0xFF0883
log.c.gray = 0xC4C4C4
log.c.cyan = 0x67FFF0
log.c.purple = 0x9A5FEB
log.c.blue = 0x0092FF
log.c.green = 0x8CE10B
log.c.red = 0xFF000F
log.c.black = 0x000000

	-- METHODS

function	log.print_to_file(str)
	if not log.fd then
		log.fail("log.fd: log file not opened")
		return
	end

	log.fd:write(str)
end

function	log.print(str, mode)
	mode = mode or 0x3

	if mode & 0x1 == 0x1 then term.write(str)
	end -- print to out
	if mode & 0x2 == 0x2 then log.print_to_file(str)
	end -- print to file
end

function	log.printc(str, foreground, background, mode)
	local	b_foreground, b_background = gpu.getForeground(), gpu.getBackground()

	gpu.setForeground(foreground or log.c.white)
	gpu.setBackground(background or log.c.black)
	log.print(str, mode)
	gpu.setForeground(b_foreground)
	gpu.setBackground(b_background)
end

function	wrapper_header(header, foreground, str, mode)
	log.print("[")
	log.printc(computer.uptime(), log.c.yellow)
	log.print("]")
	log.print("[")
	log.printc(header, foreground)
	log.print("]")
	log.print(log.sep..str.."\n")
end

function	log.fail(str, mode)
	wrapper_header("❌", log.c.red, str, mode)
end

function	log.warn(str, mode)
	wrapper_header("⚠", log.c.orange, str, mode)
end

function	log.pass(str, mode)
	wrapper_header("✔", log.c.green, str, mode)
end

function	log.info(str, mode)
	wrapper_header("ℹ", log.c.blue, str, mode)
end

function	log.debug(str, mode)
	if log.lvl > 0 then
		wrapper_header("🛠", log.c.purple, str, mode)
	end
end

function	log.set_log_file(path)
	log.path = path or os.getenv("PWD").."/exec.log"

	if not fs.exists(log.path) then
		fd = io.open(log.path, "w")
		if not fd then
			return
		end
		fd:write("")
		fd:close()
	end

	if log.fd then log.fd:close() end

	log.fd = io.open(log.path, "a")
end

log.set_log_file()

return log
