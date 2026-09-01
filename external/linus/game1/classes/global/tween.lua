local class = NewClass()
class.className = "tween"

class.easing = {}

function class.easing.linear(t)
    return t
end

function class.easing.sineIn(t)
    return 1 - math.cos((t * math.pi) / 2)
end
function class.easing.sineOut(t)
    return math.sin((t * math.pi) / 2)
end
function class.easing.sineInOut(t)
    return 0.5 * (1 - math.cos(math.pi * t))
end

function class.easing.expIn(t)
    if t == 0 then return 0 end
    return 2 ^ (10 * (t - 1))
end
function class.easing.expOut(t)
    if t == 1 then return 1 end
    return 1 - 2 ^ (-10 * t)
end

function class.easing.backOut(t, overshoot)
    local s = overshoot or 2  -- overshoot amount
    t = t - 1
    return (t * t * ((s + 1) * t + s) + 1)
end


function class:constructor(obj, duration, easing, targetProps)
    self.id = math.getUUID()

    self.duration = duration
    self.easingFunc = easing or self.easing.linear
    self.obj = obj

    self.endFunc = nil

    self.originalProps = {}
    self.targetProps = targetProps
end

function class:apply(p)
    for key, value in pairs(self.targetProps) do
        local startValue, endValue = self.originalProps[key], self.targetProps[key]
        if type(startValue) == "table" then
            self.obj[key] = startValue:lerped(endValue, p)
        elseif  type(startValue) == "number" then
            self.obj[key] = math.lerp(startValue, endValue, p)
        end
    end
end

function class:tick(t)
    if t >= (self.startTime + self.duration) then
        self:stop()
        self:apply(1)
        if self.endFunc then self.endFunc() end
        return
    end
    local p = (t - self.startTime) / self.duration
    self:apply(self.easingFunc(p))
end

function class:play()
    local t = love.timer.getTime()
    self.startTime = t

    for key, value in pairs(self.targetProps) do
        local ogValue = self.obj[key]
        if type(ogValue) == "table" and ogValue.className and ogValue.className == "vector" then
            self.originalProps[key] = ogValue:clone()
        else
            self.originalProps[key] = ogValue
        end
    end

    Tweens[self.id] = self
end

function class:stop()
    Tweens[self.id] = nil
end

return class