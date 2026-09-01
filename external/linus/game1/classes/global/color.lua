local class = NewClass()
class.className = "color"

function class:constructor(r, g, b)
    self.r = r or 0
    self.g = g or 0
    self.b = b or 0
end

function class:clone()
    return class:new(self.r, self.g, self.b)
end

return class