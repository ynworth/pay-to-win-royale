local drawer = require("lib.drawer")
local signals = require("lib.signals")

local class = NewClass(require("classes.entity"))
class.className = "coin"
class.layer = Layers.collectible
class.affectedLayers = {
    [1] = true,
}
class.tags = {}

class.showRot = false
class.flipRotX = false
class.flipRotY = false

class.sprite = Sprites.coin

class.lifeTime = 60

function class:constructor()
    class._base.constructor(self, true, nil, true)
    self.transform.moveVec = Vec:new(1, 0)

    self.transform.vel = Vec:new():random(10)
    self.rng = math.random()

    self.isCollected = false

    local t = love.timer.getTime()
    self.spawnTime = t
    self.beginTime = t + (0.1 + math.random()*0.5)

    self.offset = require("classes.transform"):new(
        Vec:new(),  --pos
        0,          --hasRot
        nil,        --scale
        nil         --hasVel
    )
    
end

function class:collect()
    PlaySound("coin", 1.2, 0.2, 1.5)

    Player.coins = Player.coins + 1

    EmitParticle(require("classes.particles.cashFlash"), self.transform.pos)
    EmitParticle(require("classes.particles.flash"), self.transform.pos)

    self:remove()
end

function class:animTick(t)
    local random = self.rng*10
    self.offset.pos.y = math.sin(t*4 + random)*7
    self.offset.pos.x = math.cos(t*4 + random)*3
    self.offset.rot = math.sin(t*4 + random - 1)*10
end

function class:tick(t)
    class._base.tick(self)

    if self.isCollected == false then

        local dist = (Player.transform.pos:clone():sub(self.transform.pos)):magnitude()

        if dist < SPRITE_SCALE*7 then
            self.isCollected = true
            return
        end
        if dist > FAR_DISTANCE then
            self:remove()
            return
        end
        if (self.spawnTime+self.lifeTime) < t then
            self:remove()
            return
        end

    elseif t > self.beginTime then
        if self.collisions then
            for _,entity in pairs(self.collisions) do
                if entity == Player then
                    self:collect()
                    return
                end
            end
        end

        self.lookVec = self.transform.pos:getLookVec(Player.transform.pos)
        self.transform.rot = self.lookVec:angleDeg()

        self.transform.vel:add(self.lookVec:clone():mul(5))
    end

    self.transform.vel:mul(0.9)
    self.transform.pos:add(self.transform.vel:clone())

    self:animTick(t)
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