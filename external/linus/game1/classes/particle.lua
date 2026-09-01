local drawer = require("lib.drawer")

local class = NewClass()
class.className = "particle"

class.sprite = Sprites.placeholder

function class:constructor(pos, vel, scale, rot)
    self.transform = require("classes.transform"):new(
        pos, 
        rot or 0, 
        scale or 1, 
        vel or Vec:new(math.random()-0.5, math.random()-0.5):mul(math.random()*25)
    )
    self.id = math.getUUID()
    self.lifeTime = 0.5 + math.random()

    self.spawnTick = love.timer.getTime()
    if self.sprites then self.sprite = self.sprites[math.random(1, #self.sprites)] end
end

function class:getParams()
    return {}
end

function class:tickLife(t)
    if (self.spawnTick+self.lifeTime) < t then
        self:remove()
    end
end

function class:tick(t)
    self.transform.pos:add(self.transform.vel)
    self.transform.vel:mul(0.9)

    self:tickLife(t)
end

function class:drawParticle(d, scaleMul)
    local fPos, fRot = self.transform:getWorldFrame(d)

    drawer.drawSprite(
        self.sprite or Sprites.placeholder, 
        fPos, 
        fRot or 0, 
        self.transform.scale, 
        scaleMul,
        false,
        false,
        self.opacity,
        self.glowing,
        self.tint
    )
    return fPos, fRot or 0
end

function class:draw(d)
    return self:drawParticle(d, nil)
end

function class:remove()
    Particles[self.id] = nil
end

return class