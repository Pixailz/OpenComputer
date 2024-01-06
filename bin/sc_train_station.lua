
--- IMPORT

	--- VANILLA
	--- CUSTOM
local	periph = require("periph")
local	utils = require("utils")
local	log = require("log")

--- ATTRIBUTS
local	conf_path = nil
local	conf = nil

--- INIT
if utils.hostname then
	local	conf_path = "/usr/etc/"..utils.hostname..".lua"

	conf = loadfile(conf_path)
	if conf == nil then
		log.fail("sc_train_station: config file, "..conf_path..", not found")
	else
		conf = conf()
	end
else
	log.fail("sc_train_station: hostname not found, aborting.")
end

if conf == nil then os.exit(1) end

print(utils.enum_table(conf))
