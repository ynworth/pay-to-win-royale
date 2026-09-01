local class = NewClass(require("classes.particles.muzzleFlash"))
class.className = "cashFlash"

class.sprite = Sprites.cashFlash

function class:constructor(pos, vel)
    class._base.constructor(self, pos, vel)

    self.lifeTime = TICK_RATE*6
end

return class