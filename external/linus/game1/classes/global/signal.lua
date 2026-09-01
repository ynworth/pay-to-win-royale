local class = NewClass()
class.className = "signal"

function class:constructor()
    self.connections = {}
end

function class:fire()
    for _,func in pairs(self.connections) do
        func()
    end
end

function class:connect(func)
    table.insert(self.connections, func)
end

return class