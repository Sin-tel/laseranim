local M = {}

function M.clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end

function M.dist(x1, y1, x2, y2)
	return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end

function M.length(x, y)
	return math.sqrt(x ^ 2 + y ^ 2)
end

function M.roundTo(x, decimals)
	local mult = 10 ^ decimals
	return math.floor(x * mult + 0.5) / mult
end

function M.lerp(a, b, amount)
	return a + (b - a) * M.clamp(amount, 0, 1)
end

function M.smooth(a, b, amount)
	local t = M.clamp(amount, 0, 1)
	local m = t * t * (3 - 2 * t)
	return a + (b - a) * m
end

function M.deepcopy(orig, copies)
	copies = copies or {}
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		if copies[orig] then
			copy = copies[orig]
		else
			copy = {}
			copies[orig] = copy
			for orig_key, orig_value in next, orig, nil do
				copy[M.deepcopy(orig_key, copies)] = M.deepcopy(orig_value, copies)
			end
			setmetatable(copy, M.deepcopy(getmetatable(orig), copies))
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function M.shuffle(x)
	for i = #x, 2, -1 do
		local j = math.random(i)
		x[i], x[j] = x[j], x[i]
	end
end

function M.partial_shuffle(x)
	for _ = 1, math.random(3) do
		local i = math.random(#x)
		local j = math.random(#x)
		x[i], x[j] = x[j], x[i]
	end
end

function M.reverse(x)
	local n, m = #x, #x / 2
	for i = 1, m do
		x[i], x[n - i + 1] = x[n - i + 1], x[i]
	end
	return x
end

return M
