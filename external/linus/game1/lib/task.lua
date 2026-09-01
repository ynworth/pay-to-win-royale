Task = {}

function Task.delay(delay, func)
    local id = math.getUUID()
    DelayedFuncs[id] = {
        ["endTime"] = love.timer.getTime() + delay,
        ["func"] = func,
    }
    return id
end

function Task.cancel(id)
    DelayedFuncs[id] = nil
end