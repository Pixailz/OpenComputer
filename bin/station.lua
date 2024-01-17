
--- IMPORT

	--- VANILLA
local	event = require("event")
local	term = require("term")
	--- CUSTOM
local	periph = require("periph")
local	periph_im = require("periph-im")
local	utils = require("utils")
local	log = require("log")

--- UTILS
function	get_dot(i) return string.rep(".", i)..string.rep(" ", 3 - i) end

--- STATION
local	STATION_CONF_PATH = "/usr/etc/"

station = {}

	--- UTILS
function station.set_switch(switch, railway)
	for _, id in ipairs(switch) do
		local	s = station.conf.switch[id]
		local	rw = s.railway[railway]

		if rw == nil then return end
		s.periph.setOutput(s.side, rw)
		log.pass(
			station.conf.name..": Set "..id..", to "
			..railway.." succeed."
		)
	end
end

	--- INIT
function	station.get_conf()
	local	conf_path = nil
	if utils.hostname then
		STATION_CONF_PATH = STATION_CONF_PATH..utils.hostname..".lua"
		station.conf = loadfile(STATION_CONF_PATH)
		if station.conf == nil then
			log.fail("station: Config file, "..STATION_CONF_PATH..", not found.")
		else
			station.conf = station.conf()
		end
	else
		log.fail("station: Hostname not found, aborting.")
	end
	if station.conf == nil then os.exit(1) end
end

function	station.get_peripheral()
	for p_k, p_v in pairs(station.conf.platform) do
		log.info(station.conf.name..": Setup platform "..p_k..".")

		for ad_k, ad_v in pairs(p_v.AD) do
			station.conf.platform[p_k].AD[ad_k] = periph_im.get_ad(ad_k, ad_v)
			if not station.conf.platform[p_k].AD[ad_k] then os.exit(1) end
		end

		for ac_k, ac_v in pairs(p_v.AC) do
			station.conf.platform[p_k].AC[ac_k] = periph_im.get_ac(ac_k, ac_v)
			if not station.conf.platform[p_k].AC[ac_k] then os.exit(1) end
		end
	end

	for a_k, a_v in pairs(station.conf.highway) do
		log.info(station.conf.name..": Setup highway "..a_k..".")

		station.conf.highway[a_k].AC = periph_im.get_ac("highway_"..a_k, a_v.AC)
		if not station.conf.highway[a_k].AC then os.exit(1) end

		station.conf.highway[a_k].AD = periph_im.get_ad("highway_"..a_k, a_v.AD)
		if not station.conf.highway[a_k].AD then os.exit(1) end
	end

	for a_k, a_v in pairs(station.conf.switch) do
		log.info(station.conf.name..": Setup switch "..a_k..".")

		station.conf.switch[a_k].periph = periph.redstone.get("switch_"..a_k, a_v.periph)
		if not station.conf.switch[a_k].periph then os.exit(1) end
	end

	for a_k, a_v in pairs(station.conf.arrival) do
		log.info(station.conf.name..": Setup arrival "..a_k..".")

		station.conf.arrival[a_k].AC = periph_im.get_ac("arrival_"..a_k, a_v.AC)
		if not station.conf.arrival[a_k].AC then os.exit(1) end

		station.conf.arrival[a_k].AD = periph_im.get_ad("arrival_"..a_k, a_v.AD)
		if not station.conf.arrival[a_k].AD then os.exit(1) end

		station.set_switch(
			station.conf.arrival[a_k].switch,
			station.conf.arrival[a_k].default_railway
		)
	end
end

function	station.init()
	station.get_conf(STATION_CONF_PATH)
	log.info("Setup station "..station.conf.name)
	-- utils.enum_table(station.conf)
	station.get_peripheral()
end

	--- RUN
function	station.arrival_brake(arrival, platform_id)
	arrival.AD.setTag(platform_id.."-arrived")
	arrival.AC.setThrottle(0)
	log.info(station.conf.name..": Setup brake to "..arrival.brake)
	arrival.AC.setBrake(arrival.brake)
end

function	station.platform_wait_for_arrival(platform, platform_id)
	local	i = 1
	local	msg = station.conf.name..": Waiting for arrival at platform "..platform_id

	platform.available = false
	log.info(msg)
	local	term_x, term_y = term.getCursor()
	while true do
		print(msg..get_dot(i))
		term.setCursor(term_x, term_y - 1)
		info = platform.AD["end"].getTag()

		if info == platform_id.."-arrived" then break end

		if i < 3 then
			i = i + 1
		else
			i = 1
		end
		os.sleep(utils.tick)
	end
	term.setCursor(term_x, term_y)
	platform.AD["end"].setTag(platform_id.."-at-station")
	platform.AC["end"].setBrake(1)
	platform.AC["deadend"].setBrake(1)
	platform.AC["end"].setThrottle(0)
	platform.AC["deadend"].setThrottle(0)
end

function	station.platform_wait_for_departure(platform, platform_id)
	local	term_x, term_y = term.getCursor()
	local	fmt = station.conf.name..": Train departure in %d sec (%d/60)     "
	local	info = nil

	log.info(station.conf.name..": Next departure in "..platform.depart_time.." sec")
	for i = platform.depart_time, 1, -1 do
		info = platform.AD["end"].info()
		print(string.format(fmt, i, info.passengers))
		term.setCursor(term_x, term_y - 1)
		platform.AC["end"].setBrake(1)
		platform.AC["deadend"].setBrake(1)
		platform.AC["end"].setThrottle(0)
		platform.AC["deadend"].setThrottle(0)
		os.sleep(1)
	end
	term.setCursor(term_x, term_y)

	info = platform.AD["end"].info()
	platform.AD["end"].setTag("")
	platform.AC["end"].setThrottle(platform.throttle)
	platform.AC["deadend"].setThrottle(platform.throttle)
	platform.AC["end"].setBrake(0)
	platform.AC["deadend"].setBrake(0)
	platform.available = true

	if info.passengers == 1 then
		log.info(station.conf.name..": Train go off with "..info.passengers.." passenger")
	else
		log.info(station.conf.name..": Train go off with "..info.passengers.." passengers")
	end
end

function	station.train_arrival(arrival, platform_id)
	local	platform = station.conf.platform[platform_id]
	local	info = nil

	station.arrival_brake(arrival, platform_id)
	station.set_switch(arrival.switch, platform_id)
	station.platform_wait_for_arrival(platform, platform_id)
	log.pass(station.conf.name..": Train successfully arrived at platform "..platform_id)
	station.platform_wait_for_departure(platform, platform_id)
end

function	station.get_available_platform(arrival_id)
	for _, rw in ipairs(station.conf.arrival[arrival_id].railway) do
		local	railway = station.conf.platform[rw]
		local	railway_type = 1

		if not railway then
			railway = station.conf.highway[rw]
			railway_type = 2
		end

		if not railway then
			log.error(station.conf.name..": Railway "..rw.." not found")
			return 0
		end

		if railway.available then
			if railway_type == 1 then
				log.pass(station.conf.name..": Platform "..rw.." available")
			else
				log.pass(station.conf.name..": Highway "..rw.." available")
			end
			return railway_type, rw
		end
	end
	return 0
end

function	station.platform_wait_for_leaving(highway, highway_id)
	local	i = 1
	local	msg = station.conf.name..": Waiting for train to through the "..highway_id.." highway"

	highway.available = false
	log.info(msg)
	local	term_x, term_y = term.getCursor()
	while true do
		print(msg..get_dot(i))
		term.setCursor(term_x, term_y - 1)
		info = highway.AD.getTag()

		if info == highway_id.."-passing" then break end

		if i < 3 then
			i = i + 1
		else
			i = 1
		end
		os.sleep(utils.tick)
	end
	term.setCursor(term_x, term_y)
	platform.AD["end"].setTag("")
	log.info(station.conf.name..": Train successfully passed highway "..highway_id)
end

function	station.train_skip(arrival, highway_id)
	local	highway = station.conf.highway[highway_id]

	arrival.AD.setTag(highway_id.."-passing")
	log.info(station.conf.name..": Station full, redirect train to highway "..highway_id)
	station.set_switch(arrival.switch, highway_id)
	station.platform_wait_for_leaving(highway, highway_id)
end

function	station.run()
	station.running = true

	while station.running do
		local	info = station.conf.arrival["arrival_01"].AD.info()

		if info then
			local	retv, railway_id = station.get_available_platform("arrival_01")

			if retv == 1 then
				station.train_arrival(station.conf.arrival["arrival_01"], railway_id)
			elseif retv == 2 then
				station.train_skip(station.conf.arrival["arrival_01"], railway_id)
			elseif retv == 0 then
				log.fail("PANIC ERROR")
			end
		end
		os.sleep(utils.tick)
	end
end

--- MAIN

station.init()
station.run()
