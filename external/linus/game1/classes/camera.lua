local class = NewClass()
class.className = "camera"

function class:constructor(id)
    self.transform = require("classes.transform"):new(
        Vec:new(0, 0), 
        nil, 
        nil, 
        nil,
        nil
    )
    self.id = id
    self.zoom = 2
    self.shakeVec = Vec:new()
    self.shake = 0
    self.target = nil
end

function class:screenshake(amount, duration)
    if self.shakeTween then self.shakeTween:stop() end

    self.shake = math.max(amount or 5, self.shake)

    self.shakeTween = Tween:new(self, duration or 1, Tween.easing.expOut, {
        ["shake"] = 0,
    })
    self.shakeTween:play()
end

function class:tick(t)
    if self.target then
        self.transform.pos:lerp(self.target.pos:clone(), 0.15)
    end
end

function class:upd(t)
    --self.shakeVec = Vec:new(math.random()-0.5, math.random()-0.5):mul(2*self.shake)
    local frequency = 20
    self.shakeVec = Vec:new(
        love.math.noise(t*frequency), 
        love.math.noise(-t*frequency)
    ):mul(2*self.shake)
end

return class