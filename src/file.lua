file = {}

file.xres = 512

function file.export()
	local name = tostring(os.date("%a %b %d %H.%M.%S"))
	print(name)

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
	-- love.filesystem.write(name .. ".sav", serialized)
end

function file.load()
	-- todo
end

function file.openFolder()
	love.system.openURL("file://" .. love.filesystem.getSaveDirectory())
end
