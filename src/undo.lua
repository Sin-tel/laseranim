local Util = require("util")

local Undo = {}

Undo.maxSize = 50

function Undo.load()
	Undo.stack = {}
	Undo.index = 0
	Undo.register()
end

-- these should be symmetric -----------
function Undo.get()
	local t = {}
	t.frameIndex = frameIndex
	t.frames = Util.deepcopy(frames)
	t.fileName = fileName
	return t
end

function Undo.set(t)
	frameIndex = t.frameIndex
	frames = Util.deepcopy(t.frames)
	fileName = t.fileName
end
----------------------------------------

function Undo.register()
	Undo.index = Undo.index + 1
	for i = #Undo.stack, Undo.index, -1 do
		Undo.stack[i] = nil
	end
	local t = Undo.get()

	Undo.stack[Undo.index] = t

	if #Undo.stack > Undo.maxSize then
		table.remove(Undo.stack, 1)
		Undo.index = Undo.index - 1
	end
end

function Undo.undo()
	Undo.index = Undo.index - 1
	if Undo.index >= 1 then
		Undo.set(Undo.stack[Undo.index])
	else
		Undo.index = 1
		print("nothing to Undo!")
	end
end

function Undo.redo()
	Undo.index = Undo.index + 1
	if Undo.stack[Undo.index] then
		Undo.set(Undo.stack[Undo.index])
	else
		Undo.index = #Undo.stack
		print("nothing to redo!")
	end
end

return Undo
