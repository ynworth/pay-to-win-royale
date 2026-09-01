local drawer = require("lib.drawer")
local signals = require("lib.signals")

local class = NewClass(require("classes.entity"))
class.className = "enemy"
class.layer = Layers.enemy
class.affectedLayers = {
    [1] = true,
    [2] = true,
    [3] = true
}
class.tags = {}
class.tags.enemy = true
class.states = {}

class.doesPush = true
class.sprite = Sprites.testEnemy

class.speed = 0.4
class.friction = 0.85

class.coins = 1

class.deathParticle = require("classes.particles.bits")

function class:constructor(health)
    class._base.constructor(self, true, nil, true, true)
    self.transform.moveVec = Vec:new(1, 0)
    self.lookVec = Vec:new()

    self.maxHealth = health or 20
    self.health = self.maxHealth

    self.healthBar = {
        impactVisual = self.maxHealth,
        _impactVisual = self.maxHealth,
    }

    self.rng = math.random()

    self.currentState = nil
    self.attackCooldownTime = 0

    self.offset = require("classes.transform"):new(
        Vec:new(),      --pos
        0,              --hasRot
        nil,            --scale
        nil             --hasVel
    )
    
end

function class:onDeath(lookVec)
    if self.deathParticleAmount then
        EmitParticles(self.deathParticle, self.transform.pos, self.deathParticleAmount, SPRITE_SCALE)
    else
        EmitAllParticles(self.deathParticle, self.transform.pos, SPRITE_SCALE)
    end
    local blood = require("classes.particles.blood")
    local params = blood:getParams()
    params.tint = self.bloodTint or params.tint
    EmitParticles(blood, self.transform.pos, 20, SPRITE_SCALE, lookVec, params)
    Cam:screenshake(5)
end
function class:kill(lookVec)
    SpawnCoins(self.transform.pos, self.coins)
    
    self:onDeath(lookVec)
    self:remove()
end

function class:damage(amount, lookVec)
    self.health = self.health - amount

    PlaySound("damage", 2, 0.2, 0.7)

    if self.healthTween then self.healthTween:stop() end

    self.healthTween = Tween:new(self.healthBar, 0.5, Tween.easing.linear, {
        ["impactVisual"] = self.health,
    })
    self.healthTween:play()

    self.opacity = 0.2
    Task.delay(0.1, function()
        self.opacity = 1
    end)

    if self.health <= 0 then
        self:kill(lookVec or self.transform.vel:clone():normalized())
    end
end

function class:push(entity)
    local dist = (self.transform.pos:clone():sub(entity.transform.pos)):magnitude()
    local lookVec = self.transform.pos:getLookVec(entity.transform.pos):mul(-dist/30)
    if entity.transform.vel then
        if entity.doesPush then
            lookVec:div(2)
            self.transform.vel:add(lookVec)
            entity.transform.vel:add(lookVec:mul(-1))
        else
            self.transform.vel:add(lookVec)
        end
    end
end

function class:animTick(t)
    local random = self.rng*10
    if not self.transform.moveVec:isZero() then
        self.offset.pos.y = -math.abs(math.sin(t*9 + random)*7)
        self.offset.rot = math.cos(t*9 + random)*15
    else
        self.offset.pos:lerp(Vec:new(0, -math.abs(math.sin(t*2.5 + random)*3)), 0.4)
        self.offset.rot = math.lerpAngle(self.offset.rot, math.cos(t*2.5 + random)*3, 0.2)
    end
end

function class:onCollide(entity)
    
end

function class:collidePlayer(entity)
    local t = love.timer.getTime()
    if entity == Player and t > self.attackCooldownTime then
        entity:damage(10, self.lookVec, self)
        self.isAttacking = false

        self.attackCooldownTime = t + 1
    end
end

function class:checkCollisions(t)
    if self.collisions then
        for _,entity in pairs(self.collisions) do
            self:push(entity)
            self:collidePlayer(entity)
            self:onCollide(entity)
        end
    end
end

function class:applyStates(from)
    self.states = {}
    for name, state in pairs(from.states) do
        self.states[name] = state:new()
    end
end

function class:stateTick(t)
    self.states[self.currentState]:tick(self, t)
end

function class:setState(newState)
    local t = love.timer.getTime()
    if self.currentState then self.states[self.currentState]:stop(self, t) end
    self.currentState = newState
    local state = self.states[newState]
    if state == nil then
        AddError(self.currentState .. " is not a valid state for " .. self.className)
        for name, state in pairs(self.states) do
            AddError("  | " .. self.className .. ": " .. name)
        end
        self:remove()
        return
    end
    state:start(self, t)
end

function class:tick(t)
    class._base.tick(self)

    self:checkCollisions(t)

    --self.lookVec = self.transform.pos:getLookVec(Player.transform.pos)
    self.transform.rot = self.lookVec:angleDeg()

    self:stateTick(t)

    self.transform.vel:add(self.transform.moveVec:clone():mul(self.speed))
    self.transform.vel:mul(self.friction)

    self.transform.pos:add(self.transform.vel:clone())

    self:animTick(t)
end

function class:postTick(t)
    self.offset:tick(t)

    local hBar = self.healthBar
    hBar._impactVisual = hBar.impactVisual
end

function class:draw(d)
    class._base.draw(self, d, self.offset)

    local posB, _ = self:getSpritePos(d)
    local scale = self.transform.scale * SPRITE_SCALE
    local offsetY = (scale)/2 + 1

    local hBar = self.healthBar
    local hp = self.health / self.maxHealth
    local ip = math.lerp(hBar._impactVisual, hBar.impactVisual, d) / self.maxHealth

    if self.health < self.maxHealth then
        drawer.drawLine(
            posB:clone():add(Vec:new(-scale/2, offsetY)), 
            posB:clone():add(Vec:new(scale/2, offsetY)), 
            2,
            Color:new(0, 0, 0)
        )
        drawer.drawLine(
            posB:clone():add(Vec:new(-scale/2, offsetY)), 
            posB:clone():add(Vec:new((-scale/2) + scale*ip, offsetY)), 
            2,
            Color:new(1, 1, 0)
        )
        drawer.drawLine(
            posB:clone():add(Vec:new(-scale/2, offsetY)), 
            posB:clone():add(Vec:new((-scale/2) + scale*hp, offsetY)), 
            2,
            Color:new(1, 0, 0)
        )
    end
    
end

return class