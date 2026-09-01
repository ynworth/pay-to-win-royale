local class = NewClass()
class.className = "vector"

function class:constructor(x, y)
    self.x = x or 0
    self.y = y or 0
end

function class:applyDeg(deg)
    local rad = math.rad(deg)
    self.x = math.cos(rad)
    self.y = math.sin(rad)
    return self
end

function class:set(x, y)
    self.x = x or self.x
    self.y = y or self.y
end

function class:add(vector)
    self.x = self.x + vector.x
    self.y = self.y + vector.y
    return self
end

function class:sub(vector)
    self.x = self.x - vector.x
    self.y = self.y - vector.y
    return self
end

function class:mul(num)
    self.x = self.x * num
    self.y = self.y * num
    return self
end

function class:div(num)
    self.x = self.x / num
    self.y = self.y / num
    return self
end

function class:lerp(vector, t)
    self.x = math.lerp(self.x, vector.x, t)
    self.y = math.lerp(self.y, vector.y, t)
    return self
end
function class:lerped(vector, t)
    return class:new(
        math.lerp(self.x, vector.x, t), 
        math.lerp(self.y, vector.y, t)
    )
end

function class:magnitude()
    return math.sqrt(self.x * self.x + self.y * self.y)
end
function class:magnitudeSq()
    return self.x * self.x + self.y * self.y
end

function class:isZero()
    return self.x == 0 and self.y == 0
end

function class:random(amount)
    self.x = (math.random()-0.5)*2 * amount
    self.y = (math.random()-0.5)*2 * amount
    return self
end

function class:normalized()
    local mag = self:magnitude()

    if mag == 0 then
        return class:new(0, 0)
    end

    return class:new(
        self.x / mag,
        self.y / mag
    )
end

function class:getLookVec(vector)
    local dx = vector.x - self.x
    local dy = vector.y - self.y

    local mag = math.sqrt(dx * dx + dy * dy)

    if mag == 0 then
        return class:new(0, 0)
    end

    return class:new(dx / mag, dy / mag)
end

function class:angleDeg()
    local angle = math.deg(math.atan(self.y / self.x))

    if self.x < 0 then
        angle = angle + 180
    end

    return angle % 360
end

function class:clone()
    return class:new(self.x, self.y)
end

return class