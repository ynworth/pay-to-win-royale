local drawer = {}

function drawer.drawSprite(sprite, pos, rot, scale, size, flippedX, flippedY, opacity, glow, tint)
    tint = tint or Color:new(1,1,1)
    size = size or Vec:new(1, 1)

    local zoom = Cam.zoom
    local o = (scale*SPRITE_SCALE)/2

    if glow then love.graphics.setBlendMode("add") end
    love.graphics.setColor(tint.r, tint.g, tint.b, opacity or 1)
    love.graphics.draw(
        sprite, 
        pos.x * zoom, pos.y * zoom, 
        (rot and math.rad(rot) or 0), 
        (zoom*size.x) * ((flippedX and -1) or 1), (zoom*size.y) * ((flippedY and -1) or 1),
        o,
        o
    )
    love.graphics.setColor(1, 1, 1)
    if glow then love.graphics.setBlendMode("alpha") end
end

function drawer.drawLine(pos1, pos2, width, color)
    local zoom = Cam.zoom
    color = color or Color:new()
    love.graphics.setColor(color.r, color.g, color.b)
    love.graphics.setLineWidth((width or 2) * zoom)

    love.graphics.line(
        pos1.x * zoom, pos1.y * zoom, 
        pos2.x * zoom, pos2.y * zoom
    )

    love.graphics.setLineWidth(0)
    love.graphics.setColor(1, 1, 1)
end

return drawer