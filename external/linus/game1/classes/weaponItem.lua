local class = NewClass()
class.className = "weaponItem"

class.length = 0
class.spriteRecoil = Vec:new(10, 35)

class.sprite = Sprites.testWeapon

class.shootTick = 0
class.cooldown = 0.4

class.damage = 5
class.recoil = 2

class.bullets = 1
class.spread = 15

function class:constructor()
    self.powerups = {}
end

function class:shoot()
    self.shootTick = love.timer.getTime()
end

function class:canUse()
    return (self.shootTick + self.cooldown) < love.timer.getTime()
end

function class:applyStats()
    for key, value in pairs(self.class) do
        self[key] = value
    end
    for _,powerup in pairs(self.powerups) do
        
    end
end

return class