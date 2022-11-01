local laser = {}

laser.width = 3.0
laser.color = { 1.0, 0.3, 0.3 }

laser.movespeed = 40000 -- tau timeconstant
laser.iterations = 5000 -- steps per frame in simulation
laser.tracespeed = 40 -- full laser draws per second
-------------
local x = 0
local y = 0
local vx = 0
local vy = 0
local t = 0
laser.frame = 1

local framecounter = 0
local frameblanktimer = 0

function laser.draw()
	local dt = 1 / (60 * laser.iterations)
	local tau = laser.movespeed

	local speed = laser.tracespeed * math.exp(love.math.randomNormal() * 0.05)

	love.graphics.setLineWidth(laser.width)

	local length = calculateLength(laser.frame)

	for i = 1, laser.iterations do
		local prevx, prevy = x, y

		t = t + speed * dt
		t = t % 1

		local gx, gy, alpha = trace(laser.frame, t * length)

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

		love.graphics.setLineWidth(laser.width)
		love.graphics.setColor(0.2 * laser.color[1], 0.2 * laser.color[2], 0.2 * laser.color[3], alpha)
		-- love.graphics.line(prevx, prevy, x, y)
		love.graphics.circle("fill", x, y, laser.width)

		if i % 20 == 0 then
			love.graphics.setColor(0.1 * laser.color[1], 0.1 * laser.color[2], 0.1 * laser.color[3], alpha)
			-- love.graphics.setLineWidth(laser.width * 5)
			-- love.graphics.line(prevx, prevy, x, y)
			love.graphics.circle("fill", x, y, laser.width * 3)
		end
	end
end

function laser.animate(dt)
	if animate then
		framecounter = framecounter + framespeed * dt

		if framecounter > 1 then
			framecounter = 0

			prev_i = 0
			prev_l = 0
			frameblanktimer = frameblank

			laser.frame = laser.frame + 1
			if laser.frame > #frames then
				laser.frame = 1
			end
		end
	else
		laser.frame = currentFrame
	end
end

return laser
