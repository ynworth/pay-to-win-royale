local drawer = require("lib.drawer")
local signals = require("lib.signals")

local class = NewClass(require("classes.entity"))
class.className = "medkitMachine"
class.layer = Layers.interactible
class.affectedLayers = {
    [1] = true,
}
class.tags = {}
class.tags.interactible = true

class.showRot = false
class.flipRotX = false
class.flipRotY = false

class.sprite = Sprites.medkitMachine

function class:constructor()
    class._base.constructor(self, true, 2, true, true)
    self.transform.moveVec = Vec:new(1, 0)

    self.transform.vel = Vec:new():random(10)
    self.rng = math.random()

    self.cost = 10

    self.offset = require("classes.transform"):new(
        Vec:new(),  --pos
        0,          --hasRot
        nil,        --scale
        nil         --hasVel
    )
end

function class:interact()
    if Player.coins < self.cost then return end
    Player.coins = Player.coins - self.cost

    local medkit = require("classes.medkit"):new()
    medkit.transform:set(self.transform.pos:clone())
    --medkit.lookVec = Vec:new(0, -20, 0)
    AddAlive(medkit)

    local tween1 = Tween:new(self.transform, 0.05, Tween.easing.sineOut, {
        size = Vec:new(0.75, 1.25)
    })
    local tween2 = Tween:new(self.transform, 0.3, Tween.easing.backOut, {
        size = Vec:new(1, 1)
    })
    
    
    tween1:play()
    tween1.endFunc = function ()
        tween2:play()
    end
end

function class:tick(t)
    class._base.tick(self)

    local dist = (Player.transform.pos:clone():sub(self.transform.pos)):magnitude()

    if dist > FAR_DISTANCE then
        self:remove()
        return
    end
end

function class:postTick(t)
    self.offset:tick(t)
end

function class:draw(d)
    class._base.draw(self, d, self.offset)
end

return class