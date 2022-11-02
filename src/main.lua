local Util = require("util")
local Laser = require("laser")
local File = require("file")
local Frame = require("frame")
local Undo = require("undo")
local utf8 = require("utf8")

io.stdout:setvbuf("no")

-- window size
local width = 1280
local height = 800

local aspectRatio = 21 / 9

-- drawing canvas size
canvas = {}
canvas.x = 1200
canvas.y = canvas.x / aspectRatio

frames = {}
frameIndex = 1
fileName = ""
debug = false

local cx = (width - canvas.x) / 2
local cy = cx

local pmouseX, pmouseY = 0, 0
local mouseX, mouseY = 0, 0

local previewLaser = false
local drawClosed = false
local renaming = false
local drawing = false

local onionSkinning = 1
local tool = "brush"

local clipboard = nil
local line = {}

local log = ""
local logTimer = 0
love.window.setMode(width, height, { vsync = true, resizable = false })

local lasercanvas = love.graphics.newCanvas(canvas.x, canvas.y)

local function removeFrame()
	if #frames > 1 then
		table.remove(frames, frameIndex)

		if frameIndex > #frames then
			frameIndex = #frames
		end
	else
		printLog("Error: there must be at least one frame!")
	end
end

local function insertFrame(f)
	table.insert(frames, frameIndex, f)
end

function love.load()
	math.randomseed(os.time())
	local font = love.graphics.newFont("res/sono_light.ttf", 16)
	love.graphics.setFont(font)

	love.graphics.setLineWidth(1.0)
	love.graphics.setLineStyle("smooth")

	love.graphics.setLineJoin("none")
	love.keyboard.setKeyRepeat(true)

	-- frames[1] = newFrame()
	File.loadLast()
	Undo.load()
end

function love.update(dt)
	if previewLaser then
		Laser.animate(dt)
	end

	logTimer = logTimer - dt

	pmouseX, pmouseY = mouseX, mouseY
	mouseX, mouseY = love.mouse.getPosition()

	local dx, dy = mouseX - pmouseX, mouseY - pmouseY

	local px, py = mouseX - cx, mouseY - cy
	px = Util.clamp(px, 0, canvas.x)
	py = Util.clamp(py, 0, canvas.y)

	if love.mouse.isDown(1) then
		if tool == "brush" then
			if #line == 0 then
				table.insert(line, { px, py })
			else
				local lastx, lasty = line[#line][1], line[#line][2]
				if Util.dist(lastx, lasty, px, py) > 5 then
					table.insert(line, { px, py })
				end
			end
		elseif tool == "grab" then
			if selection then
				for _, v in ipairs(selection) do
					v[1] = v[1] + dx
					v[2] = v[2] + dy
				end
			end
		end
	elseif love.mouse.isDown(2) then
		if tool == "brush" then
			if #line == 0 then
				table.insert(line, { px, py })
			else
				local lastx, lasty = line[1][1], line[1][2]
				if Util.dist(lastx, lasty, px, py) > 5 then
					line[2] = { Util.lerp(lastx, px, 0.5), Util.lerp(lasty, py, 0.5) }
					line[3] = { px, py }
				end
			end
		elseif tool == "grab" then
			for _, l in ipairs(frames[frameIndex].lines) do
				for _, v in ipairs(l) do
					v[1] = v[1] + dx
					v[2] = v[2] + dy
				end
			end
		end
	else
		Frame.optimize(frames[frameIndex])
	end
end

function love.draw()
	love.graphics.setBackgroundColor(0.14, 0.14, 0.14)

	love.graphics.setCanvas(lasercanvas)

	if previewLaser then
		love.graphics.setColor(0, 0, 0, 0.6)
		love.graphics.rectangle("fill", 0, 0, canvas.x, canvas.y)
		love.graphics.setBlendMode("add")

		Laser.draw()

		love.graphics.setBlendMode("alpha")
	else
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 0, 0, canvas.x, canvas.y)

		-- grid
		love.graphics.setLineWidth(1.0)
		love.graphics.setColor(0.0, 0.3, 0.3)
		love.graphics.line(canvas.x / 2, 0, canvas.x / 2, canvas.y)
		love.graphics.line(0, canvas.y / 2, canvas.x, canvas.y / 2)
		local ofs = canvas.y * 0.15
		love.graphics.rectangle("line", ofs, ofs, canvas.x - ofs * 2, canvas.y - ofs * 2)

		-- draw editor
		if #frames > 1 then
			if onionSkinning >= 2 then
				Frame.draw(frames[(frameIndex - 3) % #frames + 1], -2)
				Frame.draw(frames[(frameIndex + 1) % #frames + 1], 2)
			end
			if onionSkinning >= 1 then
				Frame.draw(frames[(frameIndex - 2) % #frames + 1], -1)
				Frame.draw(frames[(frameIndex - 0) % #frames + 1], 1)
			end
		end
		Frame.draw(frames[frameIndex], 0)

		-- debug
		-- love.graphics.setLineWidth(1.0)
		-- for _, p in ipairs(frames[frameIndex].points) do
		-- 	love.graphics.setColor(p[3], 1, 0)
		-- 	love.graphics.circle("line", p[1], p[2], 5)
		-- end

		if debug then
			local tx, ty =
				Frame.trace(frames[frameIndex], Frame.getLength(frames[frameIndex]) * (mouseX - cx) / canvas.x)

			love.graphics.setColor(0, 1, 1)
			love.graphics.circle("line", tx, ty, 7)
		end
	end

	love.graphics.setCanvas()
	love.graphics.push()
	love.graphics.translate(cx, cy)
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(lasercanvas)

	love.graphics.setColor(0.4, 0.4, 0.4)
	love.graphics.setLineWidth(1.0)
	love.graphics.rectangle("line", 0, 0, canvas.x, canvas.y)

	love.graphics.pop()
	--------------
	love.graphics.push()
	love.graphics.translate(cx, cy * 2 + canvas.y)

	-- UI stuff here
	love.graphics.setColor(1, 1, 1)
	local s = 20
	love.graphics.print("frame:       " .. frameIndex .. "/" .. #frames, 0, 0 * s)
	local tooltext = tool
	if tool == "brush" and drawClosed then
		tooltext = "brush (closed)"
	end
	love.graphics.print("tool:        " .. tooltext, 0, 1 * s)
	love.graphics.print("fps:         " .. Laser.framespeed, 0, 2 * s)
	love.graphics.print("trace speed: " .. Util.roundTo(Laser.tracespeed, 2), 0, 3 * s)

	if renaming then
		love.graphics.setColor(1, 1, 0)
	end
	love.graphics.print("name:        " .. fileName, 0, 4 * s)

	if logTimer > 0 then
		love.graphics.setColor(1, 1, 1, logTimer)

		love.graphics.print(log, 0, 6 * s)
	end

	--------------
	love.graphics.pop()
end

function love.textinput(t)
	if renaming then
		fileName = fileName .. t
	end
end

function love.keypressed(key)
	if renaming then
		if key == "backspace" then
			-- get the byte offset to the last UTF-8 character in the string.
			local byteoffset = utf8.offset(fileName, -1)

			if byteoffset then
				-- remove the last UTF-8 character.
				-- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(fileName, 1, -2).
				fileName = string.sub(fileName, 1, byteoffset - 1)
			end
		elseif key == "escape" or key == "return" then
			if fileName:len() == 0 then
				fileName = File.getRandomName()
			end
			renaming = false
		end
		return
	end

	if key == "escape" then
		love.event.quit()
	elseif key == "s" and love.keyboard.isDown("lctrl") then
		File.export()
	elseif key == "o" and love.keyboard.isDown("lctrl") then
		File.openFolder()
	elseif key == "n" and love.keyboard.isDown("lctrl") then
		File.new()
		Undo.register()
	elseif key == "x" and love.keyboard.isDown("lctrl") then
		clipboard = Util.deepcopy(frames[frameIndex])
		removeFrame()
		Undo.register()
	elseif key == "c" and love.keyboard.isDown("lctrl") then
		clipboard = Util.deepcopy(frames[frameIndex])
	elseif key == "r" and love.keyboard.isDown("lctrl") then
		renaming = true
	elseif key == "v" and love.keyboard.isDown("lctrl") then
		-- frames[frameIndex] = Util.deepcopy(clipboard)
		if clipboard then
			frameIndex = frameIndex + 1
			insertFrame(Util.deepcopy(clipboard))
		end
		Undo.register()
	elseif key == "z" and love.keyboard.isDown("lctrl") then
		Undo.undo()
	elseif key == "y" and love.keyboard.isDown("lctrl") then
		Undo.redo()
	elseif key == "delete" then
		removeFrame()
		Undo.register()
	elseif key == "space" then
		previewLaser = not previewLaser
		Laser.Frame = frameIndex
	elseif key == "p" then
		Laser.animate = not Laser.animate
	elseif key == "x" then
		frames[frameIndex] = Frame.new()
		Undo.register()
	elseif key == "o" then
		onionSkinning = (onionSkinning + 1) % 3
	elseif key == "i" then
		debug = not debug
	elseif key == "c" then
		drawClosed = not drawClosed
	elseif key == "b" then
		tool = "brush"
	elseif key == "g" then
		tool = "grab"
	elseif key == "n" then
		frameIndex = frameIndex + 1
		insertFrame(Frame.new())
		Undo.register()
	elseif key == "d" then
		frameIndex = frameIndex + 1
		if frameIndex > #frames then
			frameIndex = 1
		end
	elseif key == "a" then
		frameIndex = frameIndex - 1
		if frameIndex == 0 then
			frameIndex = #frames
		end
	elseif key == "w" then
		Laser.tracespeed = Laser.tracespeed * 1.5
	elseif key == "s" then
		Laser.tracespeed = Laser.tracespeed / 1.5
	elseif key == "q" then
		Laser.framespeed = Laser.framespeed - 6
		Laser.framespeed = math.max(6, Laser.framespeed)
	elseif key == "e" then
		Laser.framespeed = Laser.framespeed + 6
		Laser.framespeed = math.min(60, Laser.framespeed)
	end
end

function love.filedropped(f)
	File.load(f)
	Undo.register()
end

function love.mousepressed(x, y, button)
	if not previewLaser then
		if x >= cx and x <= canvas.x + cx and y >= cy and y <= canvas.y + cy then
			if tool == "brush" then
				drawing = true
				line = {}
				table.insert(frames[frameIndex].lines, line)
			elseif tool == "grab" then
				if button == 1 then
					selection = Frame.findLine(frames[frameIndex], x - cx, y - cy)
				end
			end
		end
	end
end

function love.mousereleased(x, y, button)
	if drawing and drawClosed and button == 1 then
		local xx, yy = line[1][1], line[1][2]
		table.insert(line, { xx, yy })
	end
	drawing = false
	Undo.register()
	selection = nil
	Frame.updatePoints(frames[frameIndex])
end

function printLog(s)
	logTimer = 3
	print(s)
	log = "" .. s
end
