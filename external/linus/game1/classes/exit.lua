local drawer = require("lib.drawer")
local signals = require("lib.signals")

local class = NewClass(require("classes.entity"))
class.className = "exit"
class.layer = Layers.interactible
class.affectedLayers = {
    [1] = true,
}
class.tags = {}
class.tags.interactible = true

class.showRot = false
class.flipRotX = false
class.flipRotY = false

class.sprite = Sprites.exit

function class:constructor()
    class._base.constructor(self, false, 1, false, false)
end

function class:interact()
    GameActive = false
end

function class:draw(d)
    class._base.draw(self, d)
end

return class