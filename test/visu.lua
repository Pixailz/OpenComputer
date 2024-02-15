-- [[ IMPORT ]] --

local	component = require("component")
local	gpu = component.gpu

-- [[ ATTRIBUTS ]] --
local	SX, SY = gpu.getResolution()

-- [[ FUNCTION ]] --
function	clear_screen()
	gpu.fill(1, 1, SX, SY, " ")
end

function	draw_block(block)

end

-- [[ MAIN ]] --
blocks = {
	["file1"] = {
		{1, 10},
		{16, 5},
	}
	["file2"] = {
		{11, 5},
		{21, 5},
	}
}
clear_screen()

-- wget -f http://pixailz.freeboxos.fr:18080/test/visu.lua /usr/bin/visu.lua
