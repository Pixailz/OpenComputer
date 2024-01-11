--- include
local	periph = require("periph")

local	periph_im = {}
local	periph_type = "periph_im"

function periph_im.get_ad(name, addr)
	local	c = periph.wrapper(periph_type, "AD", name, addr)

	return c
end

function periph_im.get_ac(name, addr)
	local	c = periph.wrapper(periph_type, "AC", name, addr)

	return c
end

return periph_im
