--[[ DNS CLASS

- utils.mkdir(path)

]]--

local utils = {}

-- IMPORT

	-- VANILLA
local	fs = require("filesystem")

	-- CUSTOM
local	log = require("log")

-- BEGIN
	-- ATTRIBUTS

function	utils.getId() return computer.address() end

utils.id = require("component").modem.address:sub(1, 8)
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

return utils
