require("util")
require("laser")
require("file")

io.stdout:setvbuf("no")

framespeed = 12 -- fps

-- blankspeed = 2 -- speedup during blank lines
blanktime = 50 -- duration of blank step (pixels)
frameblank = 0.002 -- duration of blank between frames (seconds)

-- window size
width = 1280
height = 800

aspectRatio = 21 / 9

-- drawing canvas size
canvasx = 1200
canvasy = canvasx / aspectRatio

cx = (width - canvasx) / 2
cy = cx
-- cx = 32
-- cy = 32

pmouseX, pmouseY = 0, 0
mouseX, mouseY = 0, 0

frames = {}

playing = true
preview = false
connect = false

tool = "brush"

currentFrame = 1

framecounter = 0
frameblanktimer = 0

onionSkinning = 1

love.window.setMode(width, height, { vsync = true, resizable = true })
--love.window.setMode(width, height, { vsync = true, fullscreen = false, fullscreentype = "desktop", borderless = false, resizable = true } )

lasercanvas = love.graphics.newCanvas(canvasx, canvasy)

function love.load()
	math.randomseed(os.time())
	local font = love.graphics.newFont("res/sono_light.ttf", 16)
	love.graphics.setFont(font)

	love.graphics.setLineWidth(1.0)
	love.graphics.setLineStyle("smooth")

	love.graphics.setLineJoin("none")

	-- frames[1] = newFrame()
	file.loadLast()
end

function love.update(dt)
	if playing and preview then
		framecounter = framecounter + framespeed * dt

		if framecounter > 1 then
			framecounter = 0

			prev_i = 0
			prev_l = 0
			frameblanktimer = frameblank

			currentFrame = currentFrame + 1
			if currentFrame > #frames then
				currentFrame = 1
			end
		end
	end

	pmouseX, pmouseY = mouseX, mouseY
	mouseX, mouseY = love.mouse.getPosition()

	px, py = mouseX - cx, mouseY - cy

	if drawing then
		if #line == 0 then
			table.insert(line, { px, py })
		else
			local lastx, lasty = line[#line][1], line[#line][2]
			if dist(lastx, lasty, px, py) > 5 then
				table.insert(line, { px, py })
			end
		end
	end
end

function love.draw()
	love.graphics.setBackgroundColor(0.14, 0.14, 0.14)

	love.graphics.setCanvas(lasercanvas)

	if preview then
		love.graphics.setColor(0, 0, 0, 0.6)
		love.graphics.rectangle("fill", 0, 0, canvasx, canvasy)
		love.graphics.setBlendMode("add")
		-- laser stuff here

		laser.draw()

		love.graphics.setBlendMode("alpha")
	else
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 0, 0, canvasx, canvasy)

		-- grid
		love.graphics.setLineWidth(1.0)
		love.graphics.setColor(0.0, 0.3, 0.3)
		love.graphics.line(canvasx / 2, 0, canvasx / 2, canvasy)
		love.graphics.line(0, canvasy / 2, canvasx, canvasy / 2)
		local ofs = canvasy * 0.15
		love.graphics.rectangle("line", ofs, ofs, canvasx - ofs * 2, canvasy - ofs * 2)

		--
		if #frames > 1 then
			if onionSkinning >= 2 then
				drawFrame((currentFrame - 3) % #frames + 1, -2)
				drawFrame((currentFrame + 1) % #frames + 1, 2)
			end
			if onionSkinning >= 1 then
				drawFrame((currentFrame - 2) % #frames + 1, -1)
				drawFrame((currentFrame - 0) % #frames + 1, 1)
			end
		end
		drawFrame(currentFrame, 0)

		-- debug
		-- love.graphics.setLineWidth(1.0)
		-- for _, p in ipairs(frames[currentFrame].points) do
		-- 	love.graphics.setColor(p[3], 1, 0)
		-- 	love.graphics.circle("line", p[1], p[2], 5)
		-- end

		-- local tx, ty = trace(currentFrame, calculateLength(currentFrame) * (mouseX - cx) / canvasx)

		-- love.graphics.setColor(0, 1, 1)
		-- love.graphics.circle("line", tx, ty, 7)
	end

	love.graphics.setCanvas()
	love.graphics.push()
	love.graphics.translate(cx, cy)
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(lasercanvas)

	love.graphics.setColor(0.4, 0.4, 0.4)
	love.graphics.setLineWidth(1.0)
	love.graphics.rectangle("line", 0, 0, canvasx, canvasy)

	--------------
	love.graphics.pop()
	love.graphics.push()
	love.graphics.translate(cx, cy * 2 + canvasy)

	-- UI stuff here
	love.graphics.setColor(1, 1, 1)
	local s = 20
	love.graphics.print("frame:       " .. currentFrame .. "/" .. #frames, 0, 0 * s)
	love.graphics.print("tool:        " .. tool, 0, 1 * s)
	love.graphics.print("fps:         " .. framespeed, 0, 2 * s)
	love.graphics.print("trace speed: " .. roundTo(laser.tracespeed, 2), 0, 3 * s)

	--------------
	love.graphics.pop()
end

function love.keypressed(key, isrepeat)
	if key == "escape" then
		love.event.quit()
	elseif key == "s" and love.keyboard.isDown("lctrl") then
		file.export()
	elseif key == "o" and love.keyboard.isDown("lctrl") then
		file.openFolder()
	elseif key == "n" and love.keyboard.isDown("lctrl") then
		file.new()
	elseif key == "x" and love.keyboard.isDown("lctrl") then
		clipboard = deepcopy(frames[currentFrame])
		removeFrame()
	elseif key == "c" and love.keyboard.isDown("lctrl") then
		clipboard = deepcopy(frames[currentFrame])
	elseif key == "v" and love.keyboard.isDown("lctrl") then
		-- frames[currentFrame] = deepcopy(clipboard)
		if clipboard then
			currentFrame = currentFrame + 1
			table.insert(frames, currentFrame, deepcopy(clipboard))
		end
	elseif key == "delete" then
		removeFrame()
	elseif key == "space" then
		playing = not playing
	elseif key == "x" then
		frames[currentFrame] = newFrame()
	elseif key == "o" then
		onionSkinning = (onionSkinning + 1) % 3
	elseif key == "p" then
		preview = not preview
	elseif key == "c" then
		connect = not connect
	elseif key == "b" then
		mode = "draw"
	elseif key == "n" then
		currentFrame = currentFrame + 1
		table.insert(frames, currentFrame, newFrame())
	elseif key == "d" then
		currentFrame = currentFrame + 1
		if currentFrame > #frames then
			currentFrame = 1
		end
		-- if not frames[currentFrame] then
		-- 	frames[currentFrame] = newFrame()
		-- end
	elseif key == "a" then
		currentFrame = currentFrame - 1
		if currentFrame == 0 then
			currentFrame = #frames
		end
	elseif key == "w" then
		laser.tracespeed = laser.tracespeed * 1.5
	elseif key == "s" then
		laser.tracespeed = laser.tracespeed / 1.5
	elseif key == "q" then
		framespeed = framespeed - 6
		framespeed = math.max(6, framespeed)
	elseif key == "e" then
		framespeed = framespeed + 6
		framespeed = math.min(60, framespeed)
	end
end

function love.filedropped(f)
	file.load(f)
end

function love.mousepressed(x, y, button, istouch)
	if not preview then
		if tool == "brush" then
			drawing = true
			line = {}
			-- line[0] = { mouseX - cx, mouseY - cy }
			table.insert(frames[currentFrame].lines, line)
		end
	end
end

function love.mousereleased(x, y, button, istouch, presses)
	if drawing then
		updatePoints()
	end
	drawing = false
end

function calculateLength(index)
	local l = 0
	local npoints = #frames[index].points
	for i = 1, npoints do
		v1 = frames[index].points[i]
		v2 = frames[index].points[i % npoints + 1]

		if v1[3] == 0 and not (connect and i == npoints) then
			-- l = l + dist(v1[1], v1[2], v2[1], v2[2]) / blankspeed
			l = l + blanktime
		else
			l = l + dist(v1[1], v1[2], v2[1], v2[2])
		end
	end

	return l
end

function updatePoints()
	frames[currentFrame].points = {}
	for _, l in ipairs(frames[currentFrame].lines) do
		for i, p in ipairs(l) do
			local alpha = 1.0
			if i == #l then
				alpha = 0
			end
			table.insert(frames[currentFrame].points, { p[1], p[2], alpha })
		end
	end
end

prev_i = 0
prev_l = 0
function trace(index, search)
	if #frames[index].points == 0 then
		return 0.5, 0.5, 0
	end

	local n_iter = 0

	local l = prev_l
	local npoints = #frames[index].points

	-- print("==========")

	for i = 0, npoints - 1 do
		v1 = frames[index].points[(prev_i + i) % npoints + 1]
		v2 = frames[index].points[(prev_i + i + 1) % npoints + 1]

		if (prev_i + i) % npoints == 0 then
			l = 0
		end

		local lPrev = l

		local d = 0

		local a = v1[3]

		if v1[3] == 0 and not (connect and (prev_i + i + 1) % npoints == 0) then
			-- d = dist(v1[1], v1[2], v2[1], v2[2]) / blankspeed
			d = blanktime
		else
			d = dist(v1[1], v1[2], v2[1], v2[2])
			a = 1.0
		end

		l = l + d

		n_iter = n_iter + 1
		if l > search and lPrev < search then
			local alpha = (search - lPrev) / d

			prev_i = (prev_i + i) % npoints

			prev_l = lPrev
			if a == 0 then
				if alpha < 0.5 then
					return v1[1], v1[2], a
				else
					return v2[1], v2[2], a
				end
			else
				return lerp(v1[1], v2[1], alpha), lerp(v1[2], v2[2], alpha), a
			end
		end
	end

	return 0.5, 0.5, 0
end

function newFrame()
	return { lines = {}, points = {} }
end

function drawFrame(index, onion)
	onion = onion or 0

	nlines = #frames[index].lines
	for i = 1, nlines do
		v1 = frames[index].lines[i]
		v2 = frames[index].lines[i % nlines + 1]
		if onion == 0 then
			love.graphics.setColor(0.9, 0.9, 0.9)
			love.graphics.setLineWidth(3.0)
		else
			if onion < 0 then
				love.graphics.setColor(0.5, 0.3, 0.2, math.exp(-math.abs(onion)))
			else
				love.graphics.setColor(0.2, 0.5, 0.3, math.exp(-math.abs(onion)))
			end
			love.graphics.setLineWidth(2.0)
		end
		for j = 1, #v1 - 1 do
			love.graphics.line(v1[j][1], v1[j][2], v1[j + 1][1], v1[j + 1][2])
		end
		if onion == 0 then
			if not connect or i ~= nlines then
				love.graphics.setLineWidth(1.0)
				love.graphics.setColor(0.2, 0.2, 0.2)
			end
			love.graphics.line(v1[#v1][1], v1[#v1][2], v2[1][1], v2[1][2])

			-- if connect and i == nlines then
			-- 	love.graphics.line(v1[#v1][1], v1[#v1][2], v2[1][1], v2[1][2])
			-- end
		end
	end
end

function removeFrame()
	table.remove(frames, currentFrame)

	if currentFrame > #frames then
		currentFrame = #frames
	end
end
