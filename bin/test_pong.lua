comp		= require("component")
e			= require("event")
term		= require("term")
thread		= require("thread")
computer	= require("computer")
gpu			= comp.gpu
local sound = require("component").sound
local	DEBUG = 1

local	KEY_S = 115
local	KEY_W = 119

P1 = "Oxylev"
P2 = "Pixailz"
P = {
	[P1] = {
		["pts"] = 0,
		["y"] = 0,
		["up"] = false,
		["down"] = false,
	},
	[P2] = {
		["pts"] = 0,
		["y"] = 0,
		["up"] = false,
		["down"] = false,
	}
}
MAX_ROUND = 3
sX, sY = gpu.getResolution()
angle = 0
speed = 1
dir = 1
sliderP1x = 3
sliderP2x = sX - 3
slideSize = 5

sliderColor      = 0xFFFFFF
backgroundColor  = 0x000000

gpu.setBackground(backgroundColor)
gpu.fill(0, 0, sX + 1, sY + 1, " ")

function slider(size, x, y)
	gpu.setBackground(backgroundColor)
	gpu.fill(x, (y - ((size / 2) + 2)), 1, size + 4, " ")
	gpu.setBackground(sliderColor)
	gpu.fill(x, y - (size / 2), 1, size, " ")
	gpu.fill(0, 2, sX + 1, 1, " ")
end

local status = true

function player_input()
	while(status) do
		event_type, v2, key, v4, nickname, v6 = e.pullMultiple("key_up", "key_down")
		if(event_type == "key_down" and key == 115) then P[nickname].up = true end
		if(event_type == "key_up" and key == 115) then P[nickname].up = false end
		if(event_type == "key_down" and key == 119) then P[nickname].down = true end
		if(event_type == "key_up" and key == 119) then P[nickname].down = false end
	end
end

function game_update(P_1, P_2)
	while(status)do
		if P[P_1].up and P[P_1].y + 1 < sY then
			P[P_1].y = P[P_1].y + 1
		end
		if P[P_1].down and P[P_1].y - 3 > 3 then
			P[P_1].y = P[P_1].y - 1
		end
		if P[P_2].up and P[P_2].y + 1 < sY then
			P[P_2].y = P[P_2].y + 1
		end
		if P[P_2].down and P[P_2].y - 3 > 3 then
			P[P_2].y = P[P_2].y - 1
		end
		os.sleep(1/20)
	end
end

function game_render(P_1, P_2)
	P[P_1].y = (sY / 2)
	P[P_2].y = (sY / 2)
	while(status)do
		slider(5, sliderP1x - 1, P[P_1].y)
		slider(5, sliderP2x + 2, P[P_2].y)
		os.sleep(1/20)
	end
end

function  get_next_pixel(x, y, a, speed)
	local	c_speed = 0

	if dir > 0 then
		c_speed = math.ceil(speed)
	else
		c_speed = math.floor(speed * dir)
	end

	local	end_x = x + c_speed
	local	end_y = y + (math.abs(c_speed) * a)
	local	delta_x = end_x - x
	local	delta_y = end_y - y

	return x + delta_x, y + delta_y
end


-- function get_intersection(A, B, C, D)
-- 	-- Calculate differences
-- 	local	ABx, ABy = B[1] - A[1], B[2] - A[2]
-- 	local	CDy = D[2] - C[2]
-- 	-- Solve the system of equations
-- 	local	det = ABx * CDy
-- 	if det == 0 then
-- 		-- The segments are parallel or coincident
-- 		return nil
-- 	end

-- 	local	s = ((Cx - A[1]) * ABy) / det
-- 	local	t = ((Cx - A[1]) * CDy) / det

-- 	-- Check if the intersection point is within both segments
-- 	if s >= 0 and s <= 1 and t >= 0 and t <= 1 then
-- 		local	iX = A[1] + t * ABx
-- 		local	iY = A[2] + t * ABy
-- 		return iX, iY
-- 	else
-- 		-- The segments do not intersect within the range [0, 1]
-- 		return nil
-- 	end
-- end

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

function ball(startX, startY)
	posX = startX
	posY = startY

	while(status)do
		tmpX = posX
		tmpY = posY

		if posY <= 3 or posY >= sY then
			angle = angle * -1
			beep_2()
		end

		local dx, dy = get_next_pixel(posX, posY, angle, speed)

		if dx > sliderP2x then
			local	iX, iY = get_intersection(
				{posX, posY},
				{dx, dy},
				{sliderP2x, P[P2].y - 3},
				{sliderP2x, P[P2].y + 2}
			)
			if iX then
				dx, dy = iX, iY
				speed = speed * 1.1
				dir = -1
				beep_1()
			else
				return P1
			end
		elseif dx < sliderP1x + 1 then
			local	iX, iY = get_intersection(
				{posX, posY},
				{dx, dy},
				{sliderP1x, P[P1].y - 3},
				{sliderP1x, P[P1].y + 2}
			)
			if iX then
				dx, dy = iX, iY
				speed = speed * 1.1
				dir = 1
				beep_1()
			else
				return P2
			end
		end

		posX = math.floor(dx)
		posY = dy

		gpu.setBackground(backgroundColor)
		gpu.fill(tmpX, tmpY, 2, 1, " ")
		gpu.setBackground(sliderColor)
		gpu.fill(posX, posY, 2, 1, " ")
		os.sleep(1/20)
	end
end

running = false
function	run()
	local tt = {
		thread.create(game_update, "Oxylev", "Pixailz"),
		thread.create(player_input),
		thread.create(game_render, "Oxylev", "Pixailz"),
	}

	while(status)do
		gpu.setBackground(backgroundColor)
		gpu.fill(0, 3, sX + 1, sY + 1, " ")
		local	msg = P1 .. ": " .. P[P1].pts .. " " .. P2 .. ": " .. P[P2].pts
		gpu.set((sX - #msg) / 2, 1, msg)

		local	winner = ball(sX / 2, sY / 2)

		P[winner].pts = P[winner].pts + 1

		speed = 1
		if winner == P1 then dir = 1 else dir = -1 end

		if P[P1].pts >= MAX_ROUND then
			gpu.setBackground(backgroundColor)
			print(P1.." win")
			status = false
		elseif P[P2].pts >= MAX_ROUND then
			gpu.setBackground(backgroundColor)
			print(P2.." win")
			status = false
		end
	end
	status = false
	thread.waitForAll(tt)
end

run()

-- game_update("Oxylev", "Pixailz")
-- player_input()
-- game_render("Oxylev", "Pixailz")
