--[[ EVENT HANDLER CLASS

-- table that holds all event handlers
-- in case no match can be found returns the dummy function unknownEvent
e_handler.event_id
]]--

local e_handler = {}

-- IMPORT

	-- VANILLA
local	event = require("event")
local	server = require("server")
local	computer = require("computer")

	-- CUSTOM
local	log = require("log")
local	utils = require("utils")

-- BEGIN
	-- UTILS
local	function stop_handler()
	e_handler.running = false
	computer.beep(1000, utils.tick_dur)
end

	-- ATTRIBUTS
e_handler.waiting_for = {}

	-- METHODS
-- e_handler.modem_message = server.recv

function e_handler.key_up(adress, char, code, player)
	local	data = {
		["key"] = string.char(char),
		["player"] = player,
	}

	return data
end

function e_handler.key_down(adress, char, code, player)
	local	data = {
		["key"] = string.char(char),
		["player"] = player,
	}

	return data
end

function	e_handler.touch(...)
	local	args = {...}
	local	retv = {
		["px"] = args[2],
		["py"] = args[3],
		["type"] = args[4],
		--[[
			0 = left click,
			1 = right click
		]]--
		["player"] = args[5],
	}
	return retv
end

function	e_handler.interrupted(uptime) return end

local	function	is_waited(event_id)
	for _, k in ipairs(e_handler.waiting_for) do
		if k == event_id then
			log.debug(event_id.." is waited")
			return true
		end
	end
	log.debug(event_id.." is not waited")
	return false
end

local	function handle(event_id, ...)
	log.debug("e_handler: handler: received "..event_id)
	if event_id and e_handler[event_id] then
		local	ret = e_handler[event_id](...)

		if is_waited(event_id) then
			stop_handler()
			return event_id, ret
		end
	end
	return nil, nil
end

function	e_handler.set_waiting(...)
	local	args = {...}
	if not #args then
		e_handler.waiting_for = {}
	else
		e_handler.waiting_for = {...}
	end
end

function	e_handler.pull(...)
	e_handler.running = true
	local	event_id
	local	ret = {}

	while e_handler.running do
		retv, event_id, d1, d2, d3, d4, d5, d6, d7, d9, d10 = pcall(
			event.pullMultiple, table.unpack(e_handler.waiting_for))

		if retv then
			event_id, ret = handle(
				event_id, d1, d2, d3, d4, d5, d6, d7, d9, d10)
		else
			return "force_interrupted", nil
		end
	end
	log.debug("exiting e_handler.pull()")
	return event_id, ret
end

return e_handler
