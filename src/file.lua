local binser = require("lib/binser")
local words = require("words")

local file = {}

file.xres = 512

function file.export()
	local name = fileName:match("([^_]+)")
	local newName = name
	local number = 2
	while love.filesystem.getInfo(newName .. ".sav") or love.filesystem.getInfo(newName .. ".png") do
		newName = name .. "_" .. number
		number = number + 1
	end

	fileName = newName

	---- write data
	local outCanvas = love.graphics.newCanvas(file.xres, #frames)

	local outData = outCanvas:newImageData()

	for iframe, _ in ipairs(frames) do
		local length = calculateLength(iframe)
		for i = 0, file.xres - 1 do
			local t = (i + 0.5) / file.xres
			local gx, gy, alpha = trace(iframe, t * length)
			outData:setPixel(i, iframe - 1, gx / canvasx, gy / canvasy, alpha, 1)
		end
	end

	--- save to disk

	local fileData = outData:encode("png")
	love.filesystem.write(fileName .. ".png", fileData)
	love.filesystem.write(fileName .. ".sav", binser.serialize(frames))
	love.filesystem.write("last.txt", fileName .. ".sav")

	printLog("saved: " .. fileName)
end

function file.loadLast()
	if love.filesystem.getInfo("last.txt") then
		local name = love.filesystem.read("last.txt")
		if love.filesystem.getInfo(name) then
			local f = love.filesystem.newFile(name, "r")
			file.load(f)
			return
		end
	else
		love.filesystem.write("last.txt", "a")
	end
	printLog("no last save found!")
	file.new()
end

function file.load(f)
	if file.getExtension(f) == ".sav" then
		f:open("r")
		local data = f:read()
		frames = binser.deserialize(data)[1]

		currentFrame = 1
	elseif file.getExtension(f) == ".png" then
		-- todo also read textures
		return
	else
		return
	end

	fileName = file.getName(f)
	printLog("loaded save: " .. fileName)
end

function file.new()
	fileName = file.getRandomName()
	currentFrame = 1
	frames = {}
	for i = 1, 1 do
		frames[i] = newFrame()
	end
	printLog("New file: " .. fileName)
end

function file.openFolder()
	love.system.openURL("file://" .. love.filesystem.getSaveDirectory())
end

function file.getExtension(f)
	return f:getFilename():match("^.+(%..+)$")
end

function file.getName(f)
	local _, name, _ = f:getFilename():match("^(.-)([^\\/]-)%.([^\\/%.]-)%.?$")
	return name
end

function file.getRandomName()
	return words.random()
end

return file
