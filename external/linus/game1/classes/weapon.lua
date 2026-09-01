local drawer = require("lib.drawer")
local signals = require("lib.signals")

local class = NewClass(require("classes.entity"))
class.className = "weapon"

class.showRot = true
class.flipRotX = false
class.flipRotY = true

function class:constructor(id, owner)
    class._base.constructor(self, true, 2, nil)

    self.id = id

    self.lookVec = Vec:new()
    self.handOffset = Vec:new()
    self.owner = owner or Player

    self.offset = require("classes.transform"):new(
        Vec:new(),  --pos
        0,          --hasRot
        2,          --scale
        nil         --hasVel
    )
    self.offset.recoil = 0

    signals.player.shoot:connect(function()
        self:shoot()
    end)

end

function class:postTick(t)
    self.offset:tick()
end

function class:shoot()
    local addRot = ((self.transform.rot+90)%360 > 180 and self.owner.item.spriteRecoil.y) or -self.owner.item.spriteRecoil.y
    --self.offset.pos = self.lookVec:clone():mul(-15)
    --self.offset.rot = addRot
    if self.shootTween then self.shootTween:stop() end

    self.offset.recoil = -self.owner.item.spriteRecoil.x
    self.offset.rot = addRot

    self.shootTween = Tween:new(self.offset, math.max(self.owner.item.cooldown-0.2, 0.2), Tween.easing.sineInOut, {
        ["recoil"] = 0,
        ["rot"] = 0,
    })
    self.shootTween:play()


    local muzzlePos = self.transform.pos:clone():add(self.lookVec:clone():mul(SPRITE_SCALE/2):mul(self.owner.item.length))
    EmitParticle(require("classes.particles.muzzleFlash"), muzzlePos)
    EmitParticle(require("classes.particles.flash"), muzzlePos)
    EmitParticles(require("classes.particles.spark"), self.transform.pos:clone(), 10, 5, self.lookVec)
end

local function horizontalStrength(deg)
    return math.abs(math.cos(math.rad(deg)))
end

function class:tick(t)
    class._base.tick(self)
    
    --local p = horizontalStrength(self.transform.rot)

    self.handOffset:lerp(self.lookVec:clone():mul(10):add(Vec:new(0, math.sin(t*5)*1)), 0.4)
    
    self.transform.pos = self.owner.transform.pos:clone():add(self.handOffset)--:sub(Vec:new(0, -5 * p))
    self.transform.rot = (self.transform.rot + math.sin(t*5+1)*4) % 360

    self.offset.pos = self.lookVec:clone():mul(self.offset.recoil)
    --self.offset.pos:lerp(Vec:new(), 0.2)
    --self.offset.rot = math.lerpAngle(self.offset.rot, 0, 0.2)
end

return class