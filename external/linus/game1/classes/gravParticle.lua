local drawer = require("lib.drawer")

local class = NewClass(require("classes.particle"))
class.className = "gravParticle"

class.gravity = 1

function class:constructor(pos, vel)
    class._base.constructor(self, 
        pos, 
        vel or Vec:new(math.random()-0.5, -(0.5 + math.random()*0.5)):mul(math.random()*25), 
        1, 
        math.random()*360
    )
    self.lifeTime = 0.5 + math.random()*2
    self.groundY = nil
    self.isFlying = true
end

function class:tick(t)
    self.transform.pos:add(self.transform.vel)
    --self.transform.vel:mul(0.9)
    self.transform.vel.y = self.transform.vel.y + self.gravity
    self.transform.rot = (self.transform.rot + self.transform.vel.x) % 360

    if self.isFlying then
        if self.transform.vel.y > 0 then
            self.isFlying = false
            self.groundY = self.transform.pos.y + 20 + math.random()*20
        end
    else
        if self.transform.pos.y > self.groundY then
            self.transform.pos.y = self.groundY
            self.transform.vel.y = -self.transform.vel.y*0.5
            self.transform.vel.x = self.transform.vel.x*0.75
        end
    end

    self:tickLife(t)
end

function class:draw(d)
    local t = love.timer.getTime()
    local p = (t-self.spawnTick) / self.lifeTime
    local p2 = math.clamp(1-math.abs(p-0.5)*2, 0, 1)
    local p3 = (1-Tween.easing.expIn(p))

    return self:drawParticle(d, Vec:new(p3, p3))
end

return class