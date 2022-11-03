local binser = require("lib/binser")
local Words = require("words")
local Frame = require("frame")

local File = {}

File.xres = 512

File.supportedImageFormats = { [".png"] = true, [".jpg"] = true, [".jpeg"] = true }

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
	local extension = File.getExtension(f)
	if extension == ".sav" then
		f:open("r")
		local data = f:read()
		frames = binser.deserialize(data)[1]

		for i = 1, #frames do
			bgImages[i] = {}
		end

		frameIndex = 1
		fileName = File.getName(f)
		printLog("Loaded save: " .. fileName)
	elseif File.supportedImageFormats[extension] then
		bgImages[frameIndex] = File.newImage(f)
		return
	else
		printLog("Unsupported file!")
		return
	end
end

function File.loadFolder(folder)
	local folderFiles = love.filesystem.getDirectoryItems(folder)
	table.sort(folderFiles)

	local index = 1
	for _, v in ipairs(folderFiles) do
		print(v)
		local f = folder .. "/" .. v
		local info = love.filesystem.getInfo(f)
		if info then
			if info.type == "file" then
				local extension = v:match("^.+(%..+)$"):lower()
				if File.supportedImageFormats[extension] then
					if frames[index] then
						bgImages[index] = File.newImage(f)
					else
						frames[index] = Frame.new()
						bgImages[index] = File.newImage(f)
					end
					index = index + 1
				end
			end
		end
	end
end

function File.newImage(f)
	local new = {}
	new.image = love.graphics.newImage(f)
	new.x = canvas.x / 2
	new.y = canvas.y / 2

	local w, h = new.image:getDimensions()

	new.s = math.min(canvas.x / w, canvas.y / h) * 0.8

	return new
end

function File.newImages()
	new = {}
	new.x = canvas.x / 2
	new.y = canvas.y / 2
	new.s = 1
	return new
end

function File.new()
	fileName = File.getRandomName()
	frameIndex = 1
	bgImages = File.newImages()
	frames = {}
	for i = 1, 1 do
		frames[i] = Frame.new()
		bgImages[i] = {}
	end
	printLog("New file: " .. fileName)
end

function File.openSaveFolder()
	love.system.openURL("file://" .. love.filesystem.getSaveDirectory())
end

function File.getExtension(f)
	return f:getFilename():match("^.+(%..+)$"):lower()
end

function File.getName(f)
	local _, name, _ = f:getFilename():match("^(.-)([^\\/]-)%.([^\\/%.]-)%.?$")
	return name
end

function File.getRandomName()
	return Words.random()
end

return File
