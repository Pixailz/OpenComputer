local	component = require("component")
local	event = require("event")
local	term = require("term")
local	thread = require("thread")
local	computer = require("computer")
local	gpu = component.gpu
local	sound = component.sound
local	utils = require("utils")

screenX, screenY = gpu.getResolution()
screenX, screenY = screenX, screenY

sliderP1x = 3
sliderP2x = screenX - 3
sliderSize = 5

MAX_ROUND = 3
START_SPEED = 1

local	keys = {
	["s"] = string.byte('s'),
	["w"] = string.byte('w'),
}

local	c = {
	["white"] = 0xffffff,
	["black"] = 0x000000,
	["red"] = 0xff0000,
	["green"] = 0x00ff00,
	["blue"] = 0x0000ff,
}

local	mainColor = c.white
local	backgroundColor = c.black
local	ballColor = c.white

local	game = {
	["running"] = true,
	["P1"] = "Oxylev",
	["P2"] = "Pixailz",
}

local	players = {
	[game.P1] = {
		["pts"] = 0,
		["x"] = sliderP1x,
		["y"] = screenY / 2,
		["up"] = false,
		["down"] = false,
		["color"] = c.red,
	},
	[game.P2] = {
		["pts"] = 0,
		["x"] = sliderP2x,
		["y"] = screenY / 2,
		["up"] = false,
		["down"] = false,
		["color"] = c.green,
	},
}

local	ball = {
	["speed"] = 1,
	["dir"] = 1,
	["angle"] = -1,
	["x"] = 0,
	["y"] = 0,
	["nx"] = 0,
	["ny"] = 0,
}

local	render = {}

function	players.update()
	while game.running do
		if players[game.P1].up and players[game.P1].y + 1 < screenY then
			players[game.P1].y = players[game.P1].y + 1
		end
		if players[game.P1].down and players[game.P1].y - 3 > 3 then
			players[game.P1].y = players[game.P1].y - 1
		end
		if players[game.P2].up and players[game.P2].y + 1 < screenY then
			players[game.P2].y = players[game.P2].y + 1
		end
		if players[game.P2].down and players[game.P2].y - 3 > 3 then
			players[game.P2].y = players[game.P2].y - 1
		end
		-- print(game.P1..": "..players[game.P1].y)
		-- print(game.P2..": "..players[game.P2].y)
		os.sleep(utils.tick)
	end
end

function	players.input()
	while game.running do
		local	event_type, _, key, _, nickname, _ = event.pullMultiple("interrupted", "key_up", "key_down")

		if event_type == "interrupted" then
			game.running = false
		end

		if players[nickname] then
			local	activate = true
			if event_type == "key_up" then
				activate = false
			end

			if key == keys.s then
				players[nickname].up = activate
			elseif key == keys.w then
				players[nickname].down = activate
			end
		end
	end
end

function	ball.update()
	if ball.y <= 3 or ball.y >= screenY + 1 then
		ball.angle = ball.angle * -1
		beep_2()
	end

	local	dx, dy = get_next_pixel(ball.x, ball.y, ball.angle, ball.speed)
	local	P1, P2 = players[game.P1], players[game.P2]

	if dx > sliderP2x then
		local	iX, iY = get_intersection(
			{ball.x, ball.y},
			{dx, dy},
			{sliderP2x, P2.y - 3},
			{sliderP2x, P2.y + 1}
		)
		if iX then
			dx, dy = iX, iY
			ball.speed = ball.speed * 1.1
			ball.dir = -1
			beep_1()
		else
			ball.nx = math.floor(dx)
			ball.ny = dy
			return game.P1
		end
	elseif dx < sliderP1x + 1 then
		local	iX, iY = get_intersection(
			{ball.x, ball.y},
			{dx, dy},
			{sliderP1x, P1.y - 3},
			{sliderP1x, P1.y + 1}
		)
		if iX then
			dx, dy = iX, iY
			ball.speed = ball.speed * 1.1
			ball.dir = 1
			beep_1()
		else
			ball.nx = math.floor(dx)
			ball.ny = dy
			return game.P2
		end
	end

	ball.nx = math.floor(dx)
	ball.ny = dy
	return nil
end

function	render.score()
	gpu.setBackground(mainColor)
	local	msg = game.P1 .. ": " .. players[game.P1].pts .. " " .. game.P2 .. ": " .. players[game.P2].pts
	gpu.set((screenX - #msg) / 2, 1, msg)
	os.sleep(utils.tick)
end

function	render.sliders()
	while game.running do
		local	P1y = players[game.P1].y - (sliderSize / 2)
		local	P2y = players[game.P2].y - (sliderSize / 2)

		gpu.setBackground(backgroundColor)
		gpu.fill(players[game.P1].x - 1, P1y - 2, 1, sliderSize + 4, " ")
		gpu.fill(players[game.P2].x + 2, P2y - 2, 1, sliderSize + 4, " ")
		gpu.setBackground(players[game.P1].color)
		gpu.fill(players[game.P1].x - 1, P1y, 1, sliderSize, " ")
		gpu.setBackground(players[game.P2].color)
		gpu.fill(players[game.P2].x + 2, P2y, 1, sliderSize, " ")
		os.sleep(utils.tick)
		render.score()
	end
end

function	render.ball()
	gpu.setBackground(backgroundColor)
	gpu.fill(ball.x, ball.y, 2, 1, " ")

	gpu.setBackground(ballColor)
	gpu.fill(ball.nx, ball.ny, 2, 1, " ")

	ball.x, ball.y = ball.nx, ball.ny
end

function	clear_screen()
	local c_f, c_b = gpu.getBackground(), gpu.getForeground()

	gpu.setForeground(mainColor)
	gpu.setBackground(backgroundColor)
	gpu.fill(0, 0, screenX + 1, screenY + 1, " ")
	gpu.setForeground(c_f)
	gpu.setBackground(c_b)
end

function	beep_1()
	sound.open(1)
	sound.setWave(1, sound.modes.sawtooth)
	sound.setFrequency(1, 440)
	sound.setVolume(1, 0.25)
	sound.delay(100)
	sound.process()
end

function	beep_2()
	sound.open(1)
	sound.setWave(1, sound.modes.sawtooth)
	sound.setFrequency(1, 220)
	sound.setVolume(1, 0.25)
	sound.delay(100)
	sound.process()
end

function  get_next_pixel(x, y, a, speed)
	local	c_speed = 0

	if ball.dir > 0 then
		c_speed = math.ceil(speed)
	else
		c_speed = math.floor(speed * ball.dir)
	end

	local	end_x = x + c_speed
	local	end_y = y + (math.abs(c_speed) * a)
	local	delta_x = end_x - x
	local	delta_y = end_y - y

	return x + delta_x, y + delta_y
end

function get_intersection(A, B, C, D)
	-- Calculate differences
	local ABx, ABy = B[1] - A[1], B[2] - A[2]
	local CDx, CDy = D[1] - C[1], D[2] - C[2]

	-- Solve the system of equations
	local det = ABx * CDy - ABy * CDx
	if det == 0 then
		-- The segments are parallel or coincident
		return nil
	end

	local s = ((C[1] - A[1]) * ABy - (C[2] - A[2]) * ABx) / det
	local t = ((C[1] - A[1]) * CDy - (C[2] - A[2]) * CDx) / det

	-- Check if the intersection point is within both segments
	if s >= 0 and s <= 1 and t >= 0 and t <= 1 then
		local iX = A[1] + t * ABx
		local iY = A[2] + t * ABy
		return iX, iY
	else
		-- The segments do not intersect within the range [0, 1]
		return nil
	end
end

clear_screen()

function	round()
	while game.running do
		render.score()
		game.update()
		local	winner = ball.update()
		render.ball()
		if winner ~= nil then return winner end
		os.sleep(utils.tick)
	end
end

function init_round(winner)
	if winner == game.P1 then
		ball.dir = 1
	else
		ball.dir = -1
	end
	ball.speed = START_SPEED
	-- ball.angle = math.random(0, 180) / 180
	ball.angle = 0
	ball.x = screenX / 2
	ball.y = screenY / 2
	players[game.P1].y = screenY / 2
	players[game.P2].y = screenY / 2
	gpu.setBackground(backgroundColor)
	gpu.fill(0, 3, screenX + 1, screenY + 1, " ")
end

function	run()
	local	tt = {
		thread.create(players.input),
	}
	local	winner = nil

	while game.running do
		init_round(winner)
		winner = round()
		if winner == game.P1 then
			players[game.P1].pts = players[game.P1].pts + 1
		elseif winner == game.P2 then
			players[game.P2].pts = players[game.P2].pts + 1
		end
		if	players[game.P1].pts >= MAX_ROUND or
			players[game.P2].pts >= MAX_ROUND then
			game.running = false
		end
	end
	return winner
end

function	round_threaded()
	while game.running do
		players.update()
		local	winner = ball.update()
		render.ball()
		if winner ~= nil then return winner end
		os.sleep(utils.tick)
	end
end

function	run_threaded()
	local	tt = {
		thread.create(players.input),
		thread.create(render.sliders),
		thread.create(players.update),
	}
	local	winner = nil

	while game.running do
		init_round(winner)
		winner = round_threaded()
		if winner == game.P1 then
			players[game.P1].pts = players[game.P1].pts + 1
		elseif winner == game.P2 then
			players[game.P2].pts = players[game.P2].pts + 1
		end
		if	players[game.P1].pts >= MAX_ROUND or
			players[game.P2].pts >= MAX_ROUND then
			game.running = false
		end
	end
	return winner
end

local	w = run_threaded()
local	w_pts
local	l
local	l_pts

if w == game.P1 then l = game.P2 else l = game.P1 end

w_pts = players[w].pts
l_pts = players[l].pts

gpu.setBackground(backgroundColor)
print("Winner is "..w.." with "..w_pts)
print("Looser is "..l.." with "..l_pts)
