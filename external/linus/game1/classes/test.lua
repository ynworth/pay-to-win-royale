local drawer = require("lib.drawer")

local class = NewClass(require("classes.entity"))
class.className = "test"
class.layer = 0
class.affectedLayers = {
    [0] = true,
    [1] = true
}

function class:constructor(id)
    class._base.constructor(self, true , nil, nil)
    self.transform.moveVec = Vec:new(1, 0)
    self.id = id
    self.sprite = Sprites.placeholder2
    self.showRot = true
    self.flipRotX = false

    self.testTween = Tween:new(self.transform, 2, Tween.easing.expOut, {
        ["pos"] = Vec:new(200, 0)
    })
end

function class:tick(t)
    class._base.tick(self)
    self.transform.rot = (self.transform.rot + 5) % 360
end

return class