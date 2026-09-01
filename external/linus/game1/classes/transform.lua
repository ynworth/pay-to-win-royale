local class = NewClass()
class.className = "transform"

function class:constructor(pos, rot, scale, vel, size)
    self.pos = pos or Vec:new()
    self._targetPos = self.pos:clone()
    self._lastPos = self.pos:clone()

    self.rot = rot or nil
    self._targetRot = self.rot
    self._lastRot = self.rot

    self.vel = vel or nil

    self.size = size or nil
    self._targetSize = self.size and self.size:clone()
    self._lastSize = self.size and self.size:clone()

    self.scale = scale or 1
end

function class:set(pos, rot)
    self._lastPos = pos
    self._targetPos = pos
    self.pos = pos
    
    if self.rot and rot then
        self._lastRot = rot
        self._targetRot = rot
        self.rot = rot
    end
end

function class:tick()
    self._lastPos = self._targetPos:clone()
    self._targetPos = self.pos:clone()

    if self.rot then
        self._lastRot = self._targetRot
        self._targetRot = self.rot
    end

    if self.size then
        self._lastSize = self._targetSize:clone()
        self._targetSize = self.size:clone()
    end
end

function class:getFrame(d)
    return self._lastPos:lerped(self._targetPos, d), 
            (self.rot and math.lerpAngle(self._lastRot, self._targetRot, d)),
            (self.size and self._lastSize:lerped(self._targetSize, d))
end

function class:getWorldFrame(d)
    local fPos, fRot, fSize = self:getFrame(d)
    local fScreenPos = WorldToScreenPos(fPos, d)
    return fScreenPos, fRot, fSize
end

return class