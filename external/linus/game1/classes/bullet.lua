local drawer = require("lib.drawer")

local class = NewClass(require("classes.entity"))
class.className = "bullet"
class.layer = Layers.projectile
class.affectedLayers = {
    [2] = true,
}

class.damage = 5
class.lifeTime = 6
class.knockback = 5

function class:constructor(damage)
    class._base.constructor(self, true , nil, nil)
    self.sprite = Sprites.bullet
    self.showRot = true
    self.flipRotX = false

    self.spawnTick = love.timer.getTime()

    self.speed = 15
    self.damage = damage or self.damage

    self.lookVec = Vec:new()
end

function class:tick(t)
    class._base.tick(self)
    self.transform.pos:add(self.lookVec:clone():mul(self.speed))

    if self.collisions then
        for _,entity in pairs(self.collisions) do
            if entity.tags.enemy and entity.health > 0 then
                entity:damage(self.damage, self.lookVec)
                entity.transform.vel:add(self.lookVec:clone():mul(self.knockback))
                self:remove()
                return
            end
        end
    end

    if (self.spawnTick+self.lifeTime) < t then
        self:remove()
    end
end

return class