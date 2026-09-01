local drawer = require("lib.drawer")

local class = NewClass(require("classes.particle"))
class.className = "muzzleFlash"

class.sprite = Sprites.circle
class.glowing = true
class.alwaysOnTop = true
class.tint = Color:new(1, 0.9, 0.5)
class.opacity = 0.5

function class:constructor(pos, vel)
    class._base.constructor(self, pos, vel)

    self.lifeTime = TICK_RATE*4
end

function class:tick(t)
    self:tickLife(t)
end

function class:draw(d)
    local t = love.timer.getTime()
    local p = (t-self.spawnTick) / self.lifeTime
    local p2 = math.clamp(1-math.abs(p-0.5)*2, 0, 1)
    local p3 = (1-Tween.easing.sineInOut(p)) * 2

    return self:drawParticle(d, Vec:new(p3, p3))
end


return class