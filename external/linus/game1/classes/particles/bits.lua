local drawer = require("lib.drawer")

local class = NewClass(require("classes.gravParticle"))
class.className = "bits"

class.sprites = {Sprites.guyChunk1, Sprites.guyChunk2, Sprites.guyChunk3, Sprites.guyChunk4, Sprites.guyChunk5, Sprites.guyChunk6}

function class:constructor(pos, vel)
    class._base.constructor(self, pos, vel)
end

return class