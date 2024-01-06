local	component = require("component")
local	screen_1 = "7ecf"
local	screen_2 = "028b"
local	screen_3 = "92df"
local	screen_4 = "6376"
local	gpu = "18d1"

local	vgpu = require("vgpu")

vgpu.setup(gpu)

vgpu.add(screen_1, 150, 50, true)
vgpu.add(screen_2, 150, 50, true)
vgpu.add(screen_3, 150, 50, true)
vgpu.add(screen_4, 150, 50, true)

for i = 1, 60 do
	vgpu.pnl(screen_1, "screen_1: line "..i)
	vgpu.pnl(screen_2, "screen_2: line "..i)
	vgpu.pnl(screen_3, "screen_3: line "..i)
	vgpu.pnl(screen_4, "screen_4: line "..i)
end

vgpu.reset(screen_1)
