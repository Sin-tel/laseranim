laser = {}

laser.width = 3.0
laser.color = { 1.0, 0.3, 0.3 }

laser.movespeed = 40000 -- tau timeconstant
laser.iterations = 5000 -- steps per frame in simulation
laser.tracespeed = 40 -- full laser draws per second
-------------
laser.x = 0
laser.y = 0
laser.a = 0

laser.vx = 0
laser.vy = 0

laser.t = 0

laser.frame = 1

function laser.draw(fr)
	local dt = 1 / (60 * laser.iterations)
	local tau = laser.movespeed

	local speed = laser.tracespeed * math.exp(love.math.randomNormal() * 0.05)

	love.graphics.setLineWidth(laser.width)

	local length = calculateLength(laser.frame)

	for i = 1, laser.iterations do
		local prevx, prevy = laser.x, laser.y

		laser.t = laser.t + speed * dt
		laser.t = laser.t % 1

		local gx, gy, alpha = trace(laser.frame, laser.t * length)

		if frameblanktimer > 0 then
			frameblanktimer = frameblanktimer - dt
			alpha = 0
		end
		-- critically damped system
		local ax = tau * tau * (gx - laser.x) - 2 * tau * laser.vx
		local ay = tau * tau * (gy - laser.y) - 2 * tau * laser.vy

		laser.vx = laser.vx + ax * dt
		laser.vy = laser.vy + ay * dt

		laser.x = laser.x + laser.vx * dt
		laser.y = laser.y + laser.vy * dt

		local len = dist(prevx, prevy, laser.x, laser.y)

		love.graphics.setLineWidth(laser.width)
		love.graphics.setColor(0.2 * laser.color[1], 0.2 * laser.color[2], 0.2 * laser.color[3], alpha)
		-- love.graphics.line(prevx, prevy, laser.x, laser.y)
		love.graphics.circle("fill", laser.x, laser.y, laser.width)

		if i % 20 == 0 then
			love.graphics.setColor(0.1 * laser.color[1], 0.1 * laser.color[2], 0.1 * laser.color[3], alpha)
			-- love.graphics.setLineWidth(laser.width * 5)
			-- love.graphics.line(prevx, prevy, laser.x, laser.y)
			love.graphics.circle("fill", laser.x, laser.y, laser.width * 3)
		end
	end
end
