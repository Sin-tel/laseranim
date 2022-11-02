local Frame = require("frame")

local Laser = {}

Laser.width = 3.0
Laser.color = { 1.0, 0.3, 0.3 }

Laser.movespeed = 40000 -- tau timeconstant
Laser.iterations = 5000 -- steps per Frame in simulation
Laser.tracespeed = 40 -- full laser draws per second
Laser.framespeed = 12 -- fps
Laser.playing = true

Laser.Frame = 1
-------------
local x = 0
local y = 0
local vx = 0
local vy = 0
local t = 0

local framecounter = 0
local frameblanktimer = 0
-- local blanktime = 50 -- duration of blank step (pixels)
local frameblank = 0.0001 -- duration of blank between frames (seconds)

function Laser.draw()
	local dt = 1 / (60 * Laser.iterations)
	local tau = Laser.movespeed

	local speed = Laser.tracespeed * math.exp(love.math.randomNormal() * 0.05)

	love.graphics.setLineWidth(Laser.width)

	if Laser.Frame > #frames then
		Laser.Frame = 1
	end

	local length = Frame.getLength(frames[Laser.Frame])

	for i = 1, Laser.iterations do
		t = t + speed * dt
		t = t % 1

		local gx, gy, alpha = Frame.trace(frames[Laser.Frame], t * length)

		if frameblanktimer > 0 then
			frameblanktimer = frameblanktimer - dt
			alpha = 0
		end
		-- critically damped system
		local ax = tau * tau * (gx - x) - 2 * tau * vx
		local ay = tau * tau * (gy - y) - 2 * tau * vy

		vx = vx + ax * dt
		vy = vy + ay * dt

		x = x + vx * dt
		y = y + vy * dt

		love.graphics.setLineWidth(Laser.width)
		love.graphics.setColor(0.2 * Laser.color[1], 0.2 * Laser.color[2], 0.2 * Laser.color[3], alpha)
		-- love.graphics.line(prevx, prevy, x, y)
		love.graphics.circle("fill", x, y, Laser.width)

		if i % 20 == 0 then
			love.graphics.setColor(0.1 * Laser.color[1], 0.1 * Laser.color[2], 0.1 * Laser.color[3], alpha)
			-- love.graphics.setLineWidth(Laser.width * 5)
			-- love.graphics.line(prevx, prevy, x, y)
			love.graphics.circle("fill", x, y, Laser.width * 3)
		end
	end
end

function Laser.animate(dt)
	if Laser.playing then
		framecounter = framecounter + Laser.framespeed * dt

		if framecounter > 1 then
			framecounter = 0

			Frame.resetHeuristics()

			frameblanktimer = frameblank

			Laser.Frame = Laser.Frame + 1
			if Laser.Frame > #frames then
				Laser.Frame = 1
			end
		end
	else
		Laser.Frame = frameIndex
	end
end

return Laser
