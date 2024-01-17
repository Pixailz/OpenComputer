local	vgpu = require("vgpu")
local	log = require("log")

local	screens = {
	["main"] = "446",
	["platform"] = {
		["01"] = {
			"ade",
			"769",
		},
		["02"] = {
			"737",
			"da1",
			"51c",
			"694",
		},
		["03"] = {
			"9a9",
			"387",
		},
	}
}
local	gpu = "045"
local	width = 120
local	height = 50

vgpu.setup(gpu)

vgpu.add(screens.main, width, height, true)

for part_id, part_screens in pairs(screens.platform) do
	vgpu.pnl(screens.main, "getting display for "..part_id)
	for i, device in ipairs(part_screens) do
		vgpu.add(device, width, height, true)
	end
end

function	platform_print(platform_id, str)
	for _, screen in ipairs(screens.platform[platform_id]) do
		vgpu.pnl(screen, str)
	end
end

while true do
	platform_print("01", "TEST 01")
	platform_print("02", "TEST 02")
	platform_print("03", "TEST 03")
end

vgpu.reset(screen_1)
