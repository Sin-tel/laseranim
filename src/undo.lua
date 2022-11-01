local undo = {}

undo.maxSize = 50

function undo.load()
	undo.stack = {}
	undo.index = 0
	undo.register()
end

-- these should be symmetric -----------
function undo.get()
	local t = {}
	t.currentFrame = currentFrame
	t.frames = deepcopy(frames)
	t.fileName = fileName
	return t
end

function undo.set(t)
	currentFrame = t.currentFrame
	frames = deepcopy(t.frames)
	fileName = t.fileName
end
----------------------------------------

function undo.register()
	undo.index = undo.index + 1
	for i = #undo.stack, undo.index, -1 do
		undo.stack[i] = nil
	end
	local t = undo.get()

	undo.stack[undo.index] = t

	if #undo.stack > undo.maxSize then
		table.remove(undo.stack, 1)
		undo.index = undo.index - 1
	end
end

function undo.undo()
	undo.index = undo.index - 1
	if undo.index >= 1 then
		undo.set(undo.stack[undo.index])
	else
		undo.index = 1
		print("nothing to undo!")
	end
end

function undo.redo()
	undo.index = undo.index + 1
	if undo.stack[undo.index] then
		undo.set(undo.stack[undo.index])
	else
		undo.index = #undo.stack
		print("nothing to redo!")
	end
end

return undo
