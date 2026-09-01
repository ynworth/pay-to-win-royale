local drawer = require("lib.drawer")

local class = NewClass(require("classes.particle"))
class.className = "blood"

class.sprites = {Sprites.blood1, Sprites.blood2, Sprites.blood3}
class.alwaysBehind = true

function class:constructor(pos, vel, params)
    local rot = (vel:clone():angleDeg() + ((math.random()-0.5)*2*20))%360
    local lookVec = Vec:new():applyDeg(rot)
    class._base.constructor(self, pos, lookVec:clone():mul(1+math.random()*20))
    
    params = params or self:getParams()

    self.lifeTime = 2 + math.random()*2
    self.lookVec = lookVec
    self.tint = params.tint
end

function class:getParams()
    return {
        tint = Color:new(145/255, 77/255, 80/255)
    }
end

function class:tick(t)
    self.transform.pos:add(self.transform.vel)
    self.transform.vel:mul(0.7)
    
    self:tickLife(t)
end

function class:draw(d)
    local t = love.timer.getTime()
    local p = (t-self.spawnTick) / self.lifeTime
    local p2 = math.clamp(1-math.abs(p-0.5)*2, 0, 1)
    local p3 = (1-Tween.easing.sineIn(p))

    self.opacity = p3

    return self:drawParticle(d)
end

return class