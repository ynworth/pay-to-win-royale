local drawer = require("lib.drawer")
local signals = require("lib.signals")

local class = NewClass(require("classes.entity"))
class.className = "medkit"
class.layer = Layers.interactible
class.affectedLayers = {
    [1] = true,
}
class.tags = {}
class.tags.interactible = true

class.showRot = false
class.flipRotX = false
class.flipRotY = false

class.sprite = Sprites.medkit

class.lifeTime = 60

function class:constructor()
    class._base.constructor(self, true, nil, true)
    self.transform.moveVec = Vec:new(1, 0)

    self.transform.vel = Vec:new():applyDeg(math.random(0, 360)):mul(8)
    self.rng = math.random()

    local t = love.timer.getTime()
    self.spawnTime = t

    self.offset = require("classes.transform"):new(
        Vec:new(),  --pos
        0,          --hasRot
        nil,        --scale
        nil         --hasVel
    )
    
end

function class:interact()
    Player.health = math.min(Player.health + 30, 100)

    self:remove()
end

function class:tick(t)
    class._base.tick(self)

    local dist = (Player.transform.pos:clone():sub(self.transform.pos)):magnitude()

    if dist > FAR_DISTANCE then
        self:remove()
        return
    end
    if (self.spawnTime+self.lifeTime) < t then
        self:remove()
        return
    end

    self.transform.vel:mul(0.9)
    self.transform.pos:add(self.transform.vel:clone())
end

function class:postTick(t)
    self.offset:tick(t)
end

function class:draw(d)
    local t = love.timer.getTime()
    local p = (t - self.spawnTime) / self.lifeTime

    local fadeProgress = math.max(0, (p - 0.75) * 4)
    self.opacity = 1 - math.min(fadeProgress, 1)
    class._base.draw(self, d, self.offset)
end

return class