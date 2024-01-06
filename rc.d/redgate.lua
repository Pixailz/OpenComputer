local component = require("component")
local shell = require("shell")
local term = require("term")

-- function
local function  get_gate(addr)
	if type(addr) == "table" then
		print("already initialised. skiping")
		return
	end
	local  gate = component.get(addr)
	if not gate then
		print("error: get_gate: "..addr.." not found")
		all_good = false
		return
	end
	gate = component.proxy(gate)

	gate.close(1)
	gate.close(2)
	gate.close(3)
	gate.close(4)
	gate.close(5)

	return (gate)
end

local function	open_gate(gate)
	if type(gate) == "table" then
		gate.gate.open(gate.open_side)
	end
end

local function	close_gate(gate)
	if type(gate) == "table" then
		gate.gate.close(gate.open_side)
	end
end

-- CMD
function	reset(void)
	print("reset: opening")
	open_gate(args.one)
	open_gate(args.two)
	open_gate(args.three)
	open_gate(args.four)
	open_gate(args.five)
	open_gate(args.six)
	open_gate(args.seven)
	open_gate(args.height)
	open_gate(args.nine)
	open_gate(args.ten)

	print("reset: closing")
	close_gate(args.one)
	close_gate(args.two)
	close_gate(args.three)
	close_gate(args.four)
	close_gate(args.five)
	close_gate(args.six)
	close_gate(args.seven)
	close_gate(args.height)
	close_gate(args.nine)
	close_gate(args.ten)

	print("reset: finished")
end

function	start()
	print("Init")

	for gate, opts in pairs(args) do
		opts.gate = get_gate(opts.gate)
		if opts.enable then
			for periph, addr in pairs(args[gate]["peripheral"]) do
				args[gate]["peripheral"][periph] = component.get(addr)
				if not args[gate]["peripheral"][periph] then
					print("peripheral, "..addr..", not found")
				else
					args[gate]["peripheral"][periph] = component.proxy(args[gate]["peripheral"][periph])
				end
			end
			open(gate)
		end
	end
end

-- CMD

function	open(gate)
	if not gate then
		print("redgate: open: arg needed")
		return
	end
	if not args[gate] then
		print("redgate: open: wrong arg")
		return
	end

	open_gate(args[gate])
end

function	close(gate)
	if not gate then
		print("redgate: close: arg needed")
		return
	end
	if not args[gate] then
		print("redgate: close: wrong arg")
		return
	end

	close_gate(args[gate])
end
