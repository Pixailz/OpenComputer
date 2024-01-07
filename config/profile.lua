local	shell = require("shell")
local	tty = require("tty")
local	fs = require("filesystem")
local	component = require("component")
local	term = require("term")

shell.setAlias("dir", "ls")
shell.setAlias("move", "mv")
shell.setAlias("rename", "mv")
shell.setAlias("copy", "cp")
shell.setAlias("del", "rm")
shell.setAlias("md", "mkdir")
shell.setAlias("cls", "clear")
shell.setAlias("rs", "redstone")
shell.setAlias("view", "edit -r")
shell.setAlias("help", "man")
shell.setAlias("l", "ls -lhp")
shell.setAlias("..", "cd ..")
shell.setAlias("df", "df -h")
shell.setAlias("grep", "grep --color")
shell.setAlias("more", "less --noback")
shell.setAlias("poweroff", "shutdown")
shell.setAlias("comp", "components")
shell.setAlias("vim", "edit")
shell.setAlias("reset", "resolution `cat /dev/components/by-type/gpy/0/maxResolution`")

os.setenv("EDITOR", "/bin/edit")
os.setenv("HOME", "/home")
os.setenv("IFS", " ")
os.setenv("MANPATH", "/usr/man:.")
os.setenv("PAGER", "less")
os.setenv("LS_COLORS", "di=0;36:fi=0:ln=0;33:*.lua=0;32")

shell.setWorkingDirectory(os.getenv("HOME"))

-- local	GPU="18d1"
-- local	SCREEN="7ecf"

-- SCREEN = component.get(SCREEN)

-- GPU = component.get(GPU)
-- GPU = component.proxy(GPU)

-- GPU.bind(SCREEN)

-- term.bind(GPU, false)

local	home_shrc = shell.resolve(".shrc")
if fs.exists(home_shrc) then
	loadfile(shell.resolve("source", "lua"))(home_shrc)
end

dofile("/usr/bin/lock.lua")

local	a = {
	["r"] = "[31m",
	["g"] = "[32m",
	["y"] = "[33m",
	["b"] = "[34m",
	["m"] = "[35m",
	["c"] = "[36m",
	["rst"] = "[0m",
}

local	user = a.r..os.getenv("USER")..a.rst
local	at = a.c.."@"..a.rst
local	hostname = nil
user_at_host = user

if fs.exists("/etc/hostname") then
	local file = io.open("/etc/hostname", "r")
	hostname = file:read()
	hostname = a.y..hostname..a.rst
	user_at_host = user_at_host..at..hostname
end

local	pwd_sep = a.c..":"..a.rst
local	pwd = a.g.."$PWD"..a.rst

local	shebang = a.c.."#"..a.rst

local	PS1 = "["..user_at_host..pwd_sep..pwd.."] "..shebang.." "

os.setenv("PS1", PS1)
