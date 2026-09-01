local class = NewClass()
class.className = "entityState"

function class:constructor(name)
    self.name = name
end

function class:tick(entity, t)
end
function class:start(entity)
end
function class:stop(entity)
end

return class