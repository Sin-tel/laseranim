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
