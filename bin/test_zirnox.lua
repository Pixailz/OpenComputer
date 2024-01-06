local	component = require("component")

local	log = require("log")

function	redstone_get(addr)
	local	redstone = component.proxy(component.get(addr))
	if not redstone then
		log.fail("failed to get "..addr.." redstone gate")
		return nil
	end
	return redstone
end

function	redstone_reset(gate)
	gate.setOutput(0, 0)
	gate.setOutput(1, 0)
	gate.setOutput(2, 0)
	gate.setOutput(3, 0)
	gate.setOutput(4, 0)
	gate.setOutput(5, 0)
end


local	redstone_chemical_01 = redstone_get("5938")

function	chemical_01_open()
	redstone_chemical_01.setOutput(2, 1)
	redstone_chemical_01.setOutput(4, 1)
end

function	chemical_01_close()
	redstone_chemical_01.setOutput(2, 0)
	redstone_chemical_01.setOutput(4, 0)
end

redstone_reset(redstone_chemical_01)

redstone_chemical_01.setOutput(4, 1)
redstone_chemical_01.setOutput(4, 0)
