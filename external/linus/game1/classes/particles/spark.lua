local drawer = require("lib.drawer")

local class = NewClass(require("classes.particle"))
class.className = "spark"

class.glowing = true
class.alwaysOnTop = true
class.tint = Color:new(1, 0.9, 0.5)
class.opacity = 0.5

function class:constructor(pos, vel)
    local rot = (vel:clone():angleDeg() + ((math.random()-0.5)*2*25))%360
    local lookVec = Vec:new():applyDeg(rot)
    class._base.constructor(self, pos, lookVec:clone():mul(5+math.random()*20))
    self.transform:set(self.transform.pos, rot)

    self.lifeTime = 0.1 + math.random()*0.2
    self.lookVec = lookVec
end

function class:tick(t)
    self.transform.pos:add(self.transform.vel)
    self.transform.vel:mul(0.9)

    self:tickLife(t)
end

function class:draw(d)
    local fPos, fRot = self.transform:getWorldFrame(d)

    local t = love.timer.getTime()
    local p = (t-self.spawnTick) / self.lifeTime
    local p2 = 1-math.abs(p-0.5)*2
    local p3 = Tween.easing.sineInOut(p2)

    drawer.drawLine(fPos, fPos:clone():add(self.lookVec:clone():mul(p3 * 15)), 1, self.tint)
    return fPos, fRot or 0
end

return class