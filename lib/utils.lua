--[[ DNS CLASS

- utils.mkdir(path)

]]--

local utils = {}

-- IMPORT

	-- VANILLA
local	fs = require("filesystem")
local	computer = require("computer")
local	component = require("component")

	-- CUSTOM
local	log = require("log")

-- BEGIN
	-- ATTRIBUTS

function	utils.getId() return computer.address() end

local	id = computer.address()
if component.isAvailable("modem") then
	utils.id = require("component").modem.address:sub(1, 8)
end
utils.tick = 1/20
utils.id_rsa = "/etc/id_mc_rsa"

	-- METHODS

-- 001 file
-- 010 dir
-- 100 link

function	utils.exists(path)
	local	ret = 0x0

	if fs.isDirectory(path) then
		ret = 0x2
	end

	if fs.isLink(path) then
		ret = ret | 0x4
	end

	if ret & 0x2 == 0 and ret & 0x4 == 0  then
		if fs.exists(path) then
			ret = ret | 0x1
		end
	end

	return ret
end

function	utils.mkdir(path)
	if utils.exists(path) & 0x2 == 0x2 then return true end

	if utils.exists(path) then
		log.warn("utils: mkdir: removing "..path)
		fs.remove(path)
	end

	if fs.makeDirectory(path) then
		log.pass("utils: mkdir: created "..path)
		return true
	else
		return false
	end
end

function	utils.touch(path)
	local	parent_dir

	if utils.exists(path) & 0x1 == 0 then
		local	fd

		fd = io.open(path)
		if not fd then utils.mkdir(fs.path(path)) end
		fd:write("")
		fd:close()
	end
end

utils.enum_table_lvl = 0
utils.enum_table_pad = "   "

local	function	get_pad()
	return string.rep(utils.enum_table_pad, utils.enum_table_lvl)
end

local	function enum_table(t)
	for k,v in pairs(t) do
		if v == nil then
			log.info(get_pad()..k..": nil")
		elseif type(v) == "table" then
			log.info(get_pad()..k..":")
			utils.enum_table_lvl = utils.enum_table_lvl + 1
			enum_table(v)
		elseif type(v) == "boolean" then
			if v then
				log.pass(get_pad()..k..": true")
			else
				log.fail(get_pad()..k..": false")
			end
		else
			log.info(get_pad()..k..": "..v)
		end
	end
	utils.enum_table_lvl = utils.enum_table_lvl - 1
end

function	utils.enum_table(t)
	utils.enum_table_lvl = 0
	enum_table(t)
end

local function	get_hostname()
	local	hostname = nil
	if utils.exists("/etc/hostname") & 0x1 > 0 then
		local	file = io.open("/etc/hostname")
		hostname = file:read()
		file:close()
	end
	return hostname
end

utils.hostname = get_hostname()

return utils
