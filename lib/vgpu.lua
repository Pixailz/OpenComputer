local	component = require("component")
local	term = require("term")
local	thread = require("thread")
local	computer = require("computer")
local	shell = require("shell")

local	vgpu = {}

function	vgpu.setup(gpu_addr)
	vgpu.gpu = component.get(gpu_addr)
	vgpu.gpu = component.proxy(vgpu.gpu)
	term.bind(vgpu.gpu)
end

function	vgpu.bind(screen)
	if vgpu.gpu.address ~= screen then
		vgpu.gpu.bind(vgpu[screen].addr)
	end
end

function	vgpu.add(screen, dx, dy, clear)
	vgpu[screen] = {}
	vgpu[screen].x = 1
	vgpu[screen].y = 1
	vgpu[screen].dx = dx or 150
	vgpu[screen].dy = dy or 40
	vgpu[screen].addr = component.get(screen)

	vgpu.bind(screen)
	vgpu.gpu.setResolution(vgpu[screen].dx, vgpu[screen].dy)
	if clear then term.clear() end
end

function	vgpu.get(screen)
	return vgpu[screen]
end

function	vgpu.reset(screen)
	vgpu.bind(screen)
	for screen, conf in ipairs(vgpu) do
		vgpu.gpu.bind(conf.addr)
		term.setCursor(conf.x, conf.y - 1)
	end
	vgpu.bind(screen)
end

function	vgpu.reset_cursor(screen)
	term.setCursor(vgpu[screen].x, vgpu[screen].y)
end

function	vgpu.p(screen, ...)
	vgpu.bind(screen)
	vgpu.reset_cursor(screen)
	term.write(...)
end

function	vgpu.pnl(screen, ...)
	vgpu.p(screen, ...)
	vgpu.nl(screen)
end

function	vgpu.nl(screen)
	vgpu.bind(screen)
	if vgpu[screen].y >= vgpu[screen].dy then
		term.scroll(1)
	else
		vgpu[screen].y = vgpu[screen].y + 1
	end
end

return vgpu
