function clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end

function dist(x1, y1, x2, y2)
	return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end

function length(x, y)
	return math.sqrt(x ^ 2 + y ^ 2)
end

function roundTo(x, decimals)
	mult = 10 ^ decimals
	return math.floor(x * mult + 0.5) / mult
end

function lerp(a, b, alpha)
	return a * (1 - alpha) + b * alpha
end

function deepcopy(orig, copies)
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
				copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
			end
			setmetatable(copy, deepcopy(getmetatable(orig), copies))
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function shuffle(x)
	-- for i = #x, 2, -1 do
	-- 	local j = math.random(i)
	-- 	x[i], x[j] = x[j], x[i]
	-- end
	for k = 1, math.random(3) do
		local i = math.random(#x)
		local j = math.random(#x)
		x[i], x[j] = x[j], x[i]
	end
end

function reverse(x)
	local n, m = #x, #x / 2
	for i = 1, m do
		x[i], x[n - i + 1] = x[n - i + 1], x[i]
	end
	return x
end
