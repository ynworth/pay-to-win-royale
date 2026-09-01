local debug = {}
debug.prints = {}

debug.SHOW_ENTITY_PROPERTIES = false
debug.SHOW_COLLISIONS = false
debug.LIST_ENTITIES = false

local LINE_SPACING = 15

function debug.formatNum(num)
    return num and string.format("%.2f", num) or "?"
end
function debug.formatVec(vector)
    return debug.formatNum(vector.x) .. ", " .. debug.formatNum(vector.y)
end
local function formatValue(value)
    if type(value) == "table" then
        if value.className then
            if value.className == "vector" then
                return debug.formatVec(value)
            end
            if value.className == "transform" or value.className == "tween" then
                return nil
            end
            return value.className .."{...}"
        end
        return #value > 0 and "[#"..#value.."]{...}" or "{...}"
    end
    if type(value) == "number" then
        return debug.formatNum(value)
    end
    if type(value) == "boolean" then
        return (value and "true") or "false"
    end
    if type(value) == "string" then
        return '"'..value..'"'
    end
    if type(value) == "userdata" then
        return "[userdata]"
    end
    if value == nil then
        return "nil"
    end
    return type(value).."(?)"
end

function debug.printProperties(obj, props, pos, indent, i)
    if DEBUG == false then return end
    indent = indent or 0
    pos = pos or Vec:new(0, 0)

    local font = love.graphics.getFont()

    local i = i or 0
    for name, value in pairs(props or obj) do
        local j = 1
        local formatted = formatValue(value)
        local text = formatted or "{"

        local offset = font:getWidth(name) + 20
        love.graphics.print(name .. ": ", pos.x + indent*20, pos.y + i*LINE_SPACING)
        love.graphics.setColor(0, 1, 1)
        love.graphics.print(text, pos.x + offset + indent*20, pos.y + i*LINE_SPACING)
        love.graphics.setColor(1, 1, 1)

        if formatted == nil then--table
            i = i + 1
            i = i + debug.printProperties(value, nil, pos, indent+1, i) - i - 1
        end
        i = i + 1
    end
    return i
end

function debug.printTransform(tf, origin)
    if DEBUG == false then return end
    local vector = origin or tf.pos:clone()
    if not origin then
        vector.x = vector.x + (tf.scale*SPRITE_SCALE/2)*Cam.zoom + 10
    end

    local pos = WorldToScreenPos(vector:clone()):mul(Cam.zoom)
    
    local props = {
        ["pos"] = tf.pos, 
        ["rot"] = tf.rot, 
        ["vel"] = tf.vel, 
        ["scale"] = tf.scale
    }
    debug.printProperties(tf, props, pos)
end

function debug.printEntityProperties(ent)
    if DEBUG == false then return end
    local tf = ent.transform

    local pos = WorldToScreenPos(tf.pos:clone()):mul(Cam.zoom)
    pos.x = pos.x + (tf.scale*SPRITE_SCALE/2)*Cam.zoom + 10
    
    debug.printProperties(ent, nil, pos)
end

return debug