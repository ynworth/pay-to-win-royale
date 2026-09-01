local drawer = require("lib.drawer")

local class = NewClass()
class.className = "entity"
class.tags = {}

class.sprite = Sprites.placeholder
class.showRot = false
class.flipRotX = true
class.flipRotY = false
class.collisions = nil

function class:constructor(hasRot, scale, hasVel, hasSize)
    self.transform = require("classes.transform"):new(
        nil, 
        hasRot and 0, 
        scale, 
        hasVel and Vec:new(),
        hasSize and Vec:new(1, 1)
    )
    self.id = math.getUUID()
end

function class:tick()
    
end

function class:getSpritePos(d, offset)
    local rot = self.transform.rot
    local fPos, fRot, fSize = self.transform:getWorldFrame(d)
    if self.showRot == false then fRot = 0 end
    if offset then
        local ofPos, ofRot, ofSize = offset:getFrame(d)
        fPos:add(ofPos)
        if fRot then
            fRot = (fRot + ofRot)%360
        end
    end
    return fPos, fRot or 0, fSize
end

function class:draw(d, offset, posOffset)
    local rot = self.transform.rot
    local fPos, fRot, fSize = self:getSpritePos(d, offset)

    if posOffset then
        fPos:add(posOffset)
    end
    
    if DEBUG and require("lib.debug").SHOW_COLLISIONS then
        local debugPos, _ = self.transform:getWorldFrame(1)
        local zoom = Cam.zoom
        local o = (self.transform.scale*SPRITE_SCALE)*zoom
        if self.layer == nil then
            love.graphics.setColor(1, 1, 1, 0.1)
        else
            if self.collisions then
                love.graphics.setColor(0, 1, 0, 0.2)
            else
                love.graphics.setColor(1, 0, 0, 0.2)
            end
        end
        love.graphics.rectangle("fill", debugPos.x*zoom - o/2, debugPos.y*zoom - o/2, o, o, 0, 0)
        love.graphics.setColor(1, 1, 1)
    end

    drawer.drawSprite(
        self.sprite or Sprites.placeholder, 
        fPos, 
        fRot or 0, 
        self.transform.scale, 
        fSize,
        (rot and self.flipRotX and (rot+90)%360 > 180),
        (rot and self.flipRotY and (rot+90)%360 > 180),
        self.opacity,
        self.glowing,
        self.tint
    )
    return fPos, fRot or 0
end

function class:remove()
    RemoveAlive(self)
end

return class