local drawer = require("lib.drawer")

local class = NewClass(require("classes.gravParticle"))
class.className = "slimeChunks"

class.sprites = {Sprites.slimeChunk1, Sprites.slimeChunk2, Sprites.slimeChunk3}

function class:constructor(pos, vel)
    class._base.constructor(self, pos, vel)
end

return class