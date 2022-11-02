local binser = require("lib/binser")
local Words = require("words")
local Frame = require("frame")

local File = {}

File.xres = 512

function File.export()
	local name = fileName:match("([^_]+)")
	local newName = name
	local number = 2
	while love.filesystem.getInfo(newName .. ".sav") or love.filesystem.getInfo(newName .. ".png") do
		newName = name .. "_" .. number
		number = number + 1
	end

	fileName = newName

	---- write data
	local outCanvas = love.graphics.newCanvas(File.xres, #frames)

	local outData = outCanvas:newImageData()

	for iframe, f in ipairs(frames) do
		local length = Frame.getLength(f)
		for i = 0, File.xres - 1 do
			local t = (i + 0.5) / File.xres
			local gx, gy, alpha = Frame.trace(f, t * length)
			outData:setPixel(i, iframe - 1, gx / canvas.x, gy / canvas.y, alpha, 1)
		end
	end

	--- save to disk

	local fileData = outData:encode("png")
	love.filesystem.write(fileName .. ".png", fileData)
	love.filesystem.write(fileName .. ".sav", binser.serialize(frames))
	love.filesystem.write("last.txt", fileName .. ".sav")

	printLog("saved: " .. fileName)
end

function File.loadLast()
	if love.filesystem.getInfo("last.txt") then
		local name = love.filesystem.read("last.txt")
		if love.filesystem.getInfo(name) then
			local f = love.filesystem.newFile(name, "r")
			File.load(f)
			return
		end
	else
		love.filesystem.write("last.txt", "a")
	end
	File.new()
	printLog("No last save found!")
end

function File.load(f)
	if File.getExtension(f) == ".sav" then
		f:open("r")
		local data = f:read()
		frames = binser.deserialize(data)[1]

		frameIndex = 1
	elseif File.getExtension(f) == ".png" then
		-- todo also read textures
		return
	else
		return
	end

	fileName = File.getName(f)
	printLog("loaded save: " .. fileName)
end

function File.new()
	fileName = File.getRandomName()
	frameIndex = 1
	frames = {}
	for i = 1, 1 do
		frames[i] = Frame.new()
	end
	printLog("New file: " .. fileName)
end

function File.openFolder()
	love.system.openURL("file://" .. love.filesystem.getSaveDirectory())
end

function File.getExtension(f)
	return f:getFilename():match("^.+(%..+)$")
end

function File.getName(f)
	local _, name, _ = f:getFilename():match("^(.-)([^\\/]-)%.([^\\/%.]-)%.?$")
	return name
end

function File.getRandomName()
	return Words.random()
end

return File
