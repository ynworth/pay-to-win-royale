local drawer = require("lib.drawer")

local class = NewClass(require("classes.particle"))
class.className = "flash"

class.sprite = Sprites.glow
class.glowing = true
class.alwaysOnTop = true
class.tint = Color:new(1, 0.85, 0.45)

function class:constructor(pos, vel)
    class._base.constructor(self, pos, vel, 4)

    self.lifeTime = 0.3

    self.opacityMul = 1

    local opacity = self.opacityMul

    self._lastOpacity = opacity
    self._currentOpacity = opacity
end

function class:tick(t)
    self._lastOpacity = self._currentOpacity
    self._currentOpacity = (1-((t-self.spawnTick) / (self.lifeTime))) * self.opacityMul

    self:tickLife(t)
end

function class:draw(d)
    local fPos, fRot = self.transform:getWorldFrame(d)

    local t = love.timer.getTime()
    local p = (t-self.spawnTick) / self.lifeTime
    local p2 = math.clamp(1-math.abs(p-0.5)*2, 0, 1)
    local p3 = (1-Tween.easing.sineInOut(p)) * 2

    local s = 0.5+(Tween.easing.sineOut(p))

    drawer.drawSprite(
        self.sprite or Sprites.placeholder, 
        fPos, 
        fRot or 0, 
        self.transform.scale, 
        Vec:new(s, s),
        false,
        false,
        math.lerp(self._lastOpacity, self._currentOpacity, d),
        self.glowing,
        self.tint
    )
    return fPos, fRot or 0
end

return class