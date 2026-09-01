function NewClass(base)
	local new_class = {}
	local class_mt = { __index = new_class }

	if base then
		setmetatable(new_class, { __index = base })
		new_class._base = base
	end

	function new_class:new(...)
		local obj = setmetatable({}, class_mt)
        obj.class = new_class
		if obj.constructor then
			obj:constructor(...)
		end
		return obj
	end

	return new_class
end

function math.clamp(x, min, max)
    return math.max(min, math.min(max, x))
end

function math.lerp(a, b, t)
    return a + (b - a) * t
end

function math.lerpAngle(a, b, t)
    local diff = (b - a + 180) % 360 - 180
    return a + diff * t
end


local random = math.random
local format = string.format

function math.getUUID()
    return format(
        "%08x-%04x-4%04x-%04x-%08x%04x%04x%04x",
        random(0, 0xFFFFFFFF),
        random(0, 0xFFFF),
        random(0, 0x0FFF),
        random(0, 0x3FFF) + 0x8000,
        random(0, 0xFFFFFFFF),
        random(0, 0xFFFF),
        random(0, 0xFFFF),
        random(0, 0xFFFF)
    )
end

function GetCameraOffset(d)
    d = d or 0
    return Cam.transform:getFrame(d):add(Cam.shakeVec):sub(Vec:new( Screen.w, Screen.h ):div(Cam.zoom):mul(0.5))
end

function WorldToScreenPos(pos, d)
    local offset = GetCameraOffset(d or 1)
    pos:sub(offset)
    return pos
end

function GetMouseWorldPos(d)
    local offset = Cam.transform:getFrame(d):sub(Vec:new( Screen.w, Screen.h ):div(Cam.zoom):mul(0.5))

    local x, y = love.mouse.getPosition()

    return Vec:new(x, y):div(Cam.zoom):add(offset)
end

function AddAlive(ent)
	ScheduledAlive[ent.id] = ent
end
function RemoveAlive(ent)
	Alive[ent.id] = nil
    ScheduledAlive[ent.id] = nil
end

function GetSpawn(pos, minDist)
    local rot = math.random(0, 360)
    local lookVec = Vec:new():applyDeg(rot)
    return pos:clone():add(lookVec:mul(minDist))
end

function SpawnCoins(pos, amount)
    for i = 1,amount do
        local coin = require("classes.coin"):new()
        coin.transform:set(pos:clone():add(Vec:new(math.random()-0.5, math.random()-0.5):mul(SPRITE_SCALE/2)))
        AddAlive(coin)
    end
end