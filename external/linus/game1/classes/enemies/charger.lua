local drawer = require("lib.drawer")
local signals = require("lib.signals")
local entityState = require("classes.entityState")

local class = NewClass(require("classes.enemy"))
class.className = "charger"

class.states = {}

class.doesPush = true
class.sprite = Sprites.chargerIdle

class.walkSpeed = 0.4
class.ramSpeed = 2
class.speed = class.walkSpeed
class.friction = 0.85
class.coins = 2

class.deathParticle = require("classes.particles.bits")

function class:constructor()
    local health = 25
    class._base.constructor(self, health)

    self:applyStates(class)
    self:setState("chasing")
end

function class:onDeath(lookVec)
    local particle = EmitParticle(require("classes.gravParticle"), self.transform.pos, nil, nil)
    particle.sprite = Sprites.chargerChunk1
    class._base.onDeath(self, lookVec)
end

---------

class.states.chasing = NewClass(entityState)
function class.states.chasing:tick(entity, t)
    entity.lookVec = entity.transform.pos:getLookVec(Player.transform.pos)
    entity.transform.rot = entity.lookVec:angleDeg()

    local dist = (Player.transform.pos:clone():sub(entity.transform.pos)):magnitude()
    entity.transform.moveVec = entity.lookVec:clone()

    if dist < SPRITE_SCALE*5 then
        entity:setState("charging")
    end
end

---------

class.states.charging = NewClass(entityState)
class.states.charging.duration = 1
function class.states.charging:tick(entity, t)
    entity.lookVec = entity.transform.pos:getLookVec(Player.transform.pos)
    entity.transform.moveVec = Vec:new()
    if t > self.endTime then
        entity:setState("attacking")
    end
end
function class.states.charging:start(entity, t)
    self.endTime = t + self.duration

    Tween:new(entity.transform, self.duration, Tween.easing.sineInOut, {
        ["size"] = Vec:new(1.25, 0.75),
    }):play()
end

---------

class.states.attacking = NewClass(entityState)
class.states.attacking.duration = 1
function class.states.attacking:tick(entity, t)
    entity.transform.moveVec = entity.lookVec:clone()
    if t > self.endTime then
        entity:setState("chasing")
    end
end
function class.states.attacking:start(entity, t)
    self.endTime = t + self.duration
    entity.speed = entity.ramSpeed

    Tween:new(entity.transform, self.duration/2, Tween.easing.sineInOut, {
        ["size"] = Vec:new(1, 1),
    }):play()
end
function class.states.attacking:stop(entity, t)
    entity.speed = entity.walkSpeed
end

---------

function class:animTick(t)
    self.offset.pos:lerp(Vec:new(), 0.1)
    self.offset.rot = math.lerp(self.offset.rot, 0, 0.1)

    local random = self.rng*10

    if not self.transform.moveVec:isZero() then
        local speed = (self.currentState == "attacking" and 14) or 9
        self.offset.pos.y = -math.abs(math.sin(t*speed + random)*7)
        self.offset.rot = math.cos(t*speed + random)*15
    else
        self.offset.pos:lerp(Vec:new(0, -math.abs(math.sin(t*2.5 + random)*3)), 0.4)
        self.offset.rot = math.lerpAngle(self.offset.rot, math.cos(t*2.5 + random)*3, 0.2)
    end
end

return class