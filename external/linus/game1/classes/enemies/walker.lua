local drawer = require("lib.drawer")
local signals = require("lib.signals")
local entityState = require("classes.entityState")

local class = NewClass(require("classes.enemy"))
class.className = "walker"

class.states = {}

class.doesPush = true
class.sprite = Sprites.walkerIdle

class.speed = 0.4
class.friction = 0.85
class.coins = 1

class.deathParticle = require("classes.particles.bits")

function class:constructor()
    local health = 15
    class._base.constructor(self, health)

    self:applyStates(class)
    self:setState("chasing")
end

---------

class.states.chasing = NewClass(entityState)
function class.states.chasing:tick(entity, t)
    entity.lookVec = entity.transform.pos:getLookVec(Player.transform.pos)
    entity.transform.rot = entity.lookVec:angleDeg()

    --local dist = (Player.transform.pos:clone():sub(entity.transform.pos)):magnitude()
    entity.transform.moveVec = entity.lookVec:clone()
end

---------

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

return class