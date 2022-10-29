local binser = require("lib/binser")

file = {}

file.xres = 512

function file.export()
	local name = tostring(os.date("%a %b %d %H.%M.%S"))
	print("saved: " .. name)

	---- write data
	local outCanvas = love.graphics.newCanvas(file.xres, #frames)
	love.graphics.setCanvas(canvas)
	love.graphics.clear(0, 0, 0)
	love.graphics.setCanvas()
	local outData = outCanvas:newImageData()

	for i = 0, file.xres - 1 do
		outData:setPixel(i, 0, 0, 0, 0, 1)
	end
	outData:setPixel(0, 0, 1, 1, 1, 1)
	outData:setPixel(2, 0, 1, 0, 0, 1)
	outData:setPixel(4, 0, 0, 1, 0, 1)
	outData:setPixel(6, 0, 0, 0, 1, 1)
	outData:setPixel(8, 0, 0.5, 0.5, 0.5, 1.0)

	--- save to disk

	local fileData = outData:encode("png")
	love.filesystem.write(name .. ".png", fileData)
	love.filesystem.write(name .. ".sav", binser.serialize(frames))
	love.filesystem.write("last.txt", name .. ".sav")
end

function file.loadLast()
	if love.filesystem.getInfo("last.txt") then
		local name = love.filesystem.read("last.txt")
		if love.filesystem.getInfo(name) then
			frames = binser.deserialize(love.filesystem.read(name))[1]
			print("loaded last save")
			return
		end
	else
		love.filesystem.write("last.txt", "a")
	end
	print("no last save found")
	file.new()
end

function file.load(f)
	if file.getExtension(f) == ".sav" then
		f:open("r")
		local data = f:read()
		frames = binser.deserialize(data)[1]
	elseif file.getExtension(f) == ".png" then
		-- todo also read textures
	end
end

function file.new()
	frames = {}
	frames[1] = newFrame()
end

function file.openFolder()
	love.system.openURL("file://" .. love.filesystem.getSaveDirectory())
end

function file.getExtension(f)
	return f:getFilename():match("^.+(%..+)$")
end
