local Util = require("util")

local Frame = {}

local blankspeed = 4 -- speedup during blank lines

-- trace heuristics
local prev_i = 0
local prev_l = 0

function Frame.new()
	return { lines = {}, points = {} }
end

function Frame.draw(f, onion)
	onion = onion or 0

	local nlines = #f.lines
	for i = 1, nlines do
		local v1 = f.lines[i]
		local v2 = f.lines[i % nlines + 1]
		if onion == 0 then
			if v1 == selection then
				love.graphics.setColor(0.0, 0.9, 0.9)
			else
				love.graphics.setColor(0.9, 0.9, 0.9)
			end
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
			if debug then
				-- if i ~= nlines then
				love.graphics.setLineWidth(1.0)
				love.graphics.setColor(0.2, 0.2, 0.2)
				love.graphics.line(v1[#v1][1], v1[#v1][2], v2[1][1], v2[1][2])
				-- end
			end
		end
	end
end

local function getBlankLength(lines)
	local d = 0
	local nlines = #lines
	for i = 1, nlines do
		local v1 = lines[i]
		local v2 = lines[i % nlines + 1]
		d = d + Util.dist(v1[#v1][1], v1[#v1][2], v2[1][1], v2[1][2])
	end

	return d
end

function Frame.optimize(f)
	local previousLength = getBlankLength(f.lines)

	for _ = 1, 10 do
		local newLines = (Util.deepcopy(f.lines))
		Util.partial_shuffle(newLines)

		for _, line in ipairs(newLines) do
			if math.random() < 0.1 then
				Util.reverse(line)
			end
		end

		local newLength = getBlankLength(newLines)

		if newLength < previousLength then
			-- print(newLength, previousLength)
			previousLength = newLength
			f.lines = Util.deepcopy(newLines)
			Frame.updatePoints(f)
		end
	end
end

local function distanceToLine(x, y, line)
	local d = 100000
	for _, v in ipairs(line) do
		local newD = Util.dist(x, y, v[1], v[2])
		if newD < d then
			d = newD
		end
	end
	return d
end

function Frame.findLine(f, x, y)
	local line = nil
	local d = 100
	for _, v in ipairs(f.lines) do
		local newD = distanceToLine(x, y, v)
		if newD < d then
			d = newD
			line = v
		end
	end

	return line
end

function Frame.resetHeuristics()
	prev_i = 0
	prev_l = 0
end

function Frame.trace(f, search)
	if #f.points == 0 then
		return canvas.x / 2, canvas.y / 2, 0
	end

	local n_iter = 0

	local l = prev_l
	local npoints = #f.points

	for i = 0, npoints - 1 do
		local v1 = f.points[(prev_i + i) % npoints + 1]
		local v2 = f.points[(prev_i + i + 1) % npoints + 1]

		if (prev_i + i) % npoints == 0 then
			l = 0
		end

		local lPrev = l

		local d

		local a = v1[3]

		if v1[3] == 0 then
			d = Util.dist(v1[1], v1[2], v2[1], v2[2]) / blankspeed
			-- d = blanktime
		else
			d = Util.dist(v1[1], v1[2], v2[1], v2[2])
			a = 1.0
		end

		l = l + d

		n_iter = n_iter + 1
		if l > search and lPrev < search then
			local alpha = (search - lPrev) / d

			prev_i = (prev_i + i) % npoints

			prev_l = lPrev
			if a == 0 then
				if alpha < 0.3 then
					return v1[1], v1[2], a
				else
					return v2[1], v2[2], a
				end
			else
				return Util.lerp(v1[1], v2[1], alpha), Util.lerp(v1[2], v2[2], alpha), a
			end
		end
	end

	return canvas.x / 2, canvas.y / 2, 0
end

function Frame.getLength(f)
	local l = 0
	local npoints = #f.points

	for i = 1, npoints do
		local v1 = f.points[i]
		local v2 = f.points[i % npoints + 1]

		if v1[3] == 0 then
			l = l + Util.dist(v1[1], v1[2], v2[1], v2[2]) / blankspeed
			-- l = l + blanktime
		else
			l = l + Util.dist(v1[1], v1[2], v2[1], v2[2])
		end
	end

	return l
end

function Frame.updatePoints(f)
	f.points = {}
	for _, l in ipairs(f.lines) do
		for i, p in ipairs(l) do
			local alpha = 1.0
			if i == #l then
				alpha = 0
			end
			table.insert(f.points, { p[1], p[2], alpha })
		end
	end

	prev_i = 0
	prev_l = 0
end

return Frame
