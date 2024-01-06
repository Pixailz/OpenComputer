--- include
local	comp = require("component")

---@meta
--- Base class for any component
---@class periph
local periph = {}

--- Function to get initialise any component given an address with a minimum length of 3
--- Return an initialised class on success, otherwise nil
function periph.get(name, addr)
	local	a = comp.get(addr)
	if a == nil then
		print("periph: "..name..": Error: addr ("..addr..") not found")
		return nil
	end

	local	c = comp.proxy(a)
	if c then
		print("periph: "..name..": Successfully get "..addr)
	else
		print("periph: "..name..": Error ("..addr..")")
	end
	return c
end

return periph
