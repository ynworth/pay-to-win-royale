DEBUG = true

SPRITE_SCALE = 32
TICK_RATE = 1 / 30
local accumulator = 0

require("globals")
local drawer =      require("lib.drawer")
local debug =       require("lib.debug")
local signals =     require("lib.signals")
local waveHandler = nil

function Print(str)
    table.insert(debug.prints, str)
end

local aliveMapped = {}

local function updateGame(t)
    if GameActive == false then return end
    waveHandler:tick(t)

    Cam:tick()
    Cam.transform:tick()

    aliveMapped = {}

    for _, ent in pairs(ScheduledAlive) do
        Alive[ent.id] = ent
    end
    ScheduledAlive = {}

    CheckAllCollisions()

    for _, ent in pairs(Alive) do
        SafeCall(function()
            ent:tick(t)
        end)
        table.insert(aliveMapped, {["id"] = ent.id, ["y"] = ent.transform.pos.y})
    end

    for _, particle in pairs(Particles) do
        SafeCall(function()
            particle:tick(t)
        end)
        table.insert(aliveMapped, {
            ["id"] = particle.id, 
            ["y"] = particle.transform.pos.y, 
            ["alwaysOnTop"] = particle.alwaysOnTop, 
            ["alwaysBehind"] = particle.alwaysBehind
        })
    end

    table.sort(aliveMapped, function(a, b)
        if a.alwaysBehind ~= b.alwaysBehind then
            return a.alwaysBehind == true
        end
        if a.alwaysOnTop ~= b.alwaysOnTop then
            return b.alwaysOnTop == true
        end
        return a.y < b.y
    end)

    for _, tween in pairs(Tweens) do
        SafeCall(function()
            tween:tick(t)
        end)
    end
    for id, delayed in pairs(DelayedFuncs) do
        if t > delayed.endTime then
            SafeCall(delayed.func)
            DelayedFuncs[id] = nil
        end
    end

    for _, ent in pairs(Alive) do
        if ent.transform then
            SafeCall(function()
                ent.transform:tick()
            end)
        end
        if ent.postTick then
            SafeCall(function()
                ent:postTick(t)
            end)
        end
    end

    for _, ent in pairs(Particles) do
        if ent.transform then
            SafeCall(function()
                ent.transform:tick()
            end)
        end
    end

end

function love.update(dt)
    if Cam == nil then return end
    accumulator = accumulator + dt
    local t = love.timer.getTime()

    Cam:upd(t)

    while accumulator >= TICK_RATE do
        updateGame(t)
        accumulator = accumulator - TICK_RATE
    end
end

function love.draw()
    local t = love.timer.getTime()

    love.graphics.clear(0.4, 0.4, 0.5)
    local delta = accumulator / TICK_RATE

    local fps = love.timer.getFPS()
    if fps >= 60 then love.graphics.setColor(0, 1, 0) else love.graphics.setColor(1, 0, 0) end
    love.graphics.print("FPS: " .. fps, 10, 10)
    love.graphics.setColor(1, 1, 1)

    if Cam == nil then return end

    if not (GameActive == false and #Errors > 0) then
        for _, o in pairs(aliveMapped) do
            local ent = Alive[o.id] or Particles[o.id]
            if ent then
                if ent.draw then
                    SafeCall(function()
                        ent:draw(delta)
                    end)
                end
            end
        end
    end

    local text = "Health: " .. Player.health .. " / " .. Player.maxHealth
    if Player.health < Player.maxHealth/3 then love.graphics.setColor(1, 0, 0) end
    if Player.health == Player.maxHealth then love.graphics.setColor(0, 1, 0) end
    love.graphics.setFont(Fonts.medium)
    love.graphics.print(text, Screen.w/2 - Fonts.medium:getWidth(text)/2, 30)
    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(1, 1, 1)

    local text = "Coins: " .. Player.coins
    love.graphics.setColor(1, 1, 0)
    love.graphics.setFont(Fonts.medium)
    love.graphics.print(text, Screen.w - Fonts.medium:getWidth(text) -10, 10)
    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(1, 1, 1)


    local damageDuration = 1
    local p = math.clamp((((Player.damageTick + damageDuration) or 0) - t) / damageDuration, 0, 1)
    p = Tween.easing.sineIn(p)

    love.graphics.setColor(1, 0, 0, p)
    love.graphics.draw(
        Sprites.vignette,
        0, 0,
        0,
        love.graphics.getWidth() / 1920,
        love.graphics.getHeight() / 1080
    )
    love.graphics.setColor(1, 1, 1, 1)

    if DEBUG then
        love.graphics.setColor(0, 0, 1)
        love.graphics.rectangle("fill", Screen.w/2, Screen.h/2, 2, 2)
        love.graphics.setColor(1, 1, 1)

        love.graphics.print("zoom - " .. string.format("%.3f", Cam.zoom), Screen.w/2-50, 10)

        if SHOW_ERRORS and #Errors > 0 then
            love.graphics.setColor(1, 0, 0)
            love.graphics.print("ERRORS: " .. #Errors .. " / " .. MAX_ERRORS, Screen.w/2-50, Screen.h-40)
            love.graphics.setColor(1, 1, 1)
        end

        if #debug.prints > 0 then
            love.graphics.setColor(0.5, 1, 0.5)
            for i,pr in pairs(debug.prints) do
                local str = 
                    type(pr) == "number" and debug.formatNum(pr) or
                    type(pr) == "table" and pr.className and pr.className == "vector" and debug.formatVec(pr) or
                    type(pr) == "table" and "{...}" or
                    tostring(pr)
                love.graphics.print(i .. " - " .. str, 10, (i)*-13 - 10 + Screen.h)
            end
            love.graphics.setColor(1, 1, 1)
        end
        
        local tweenCount = 0
        for _,_ in pairs(Tweens) do
            tweenCount = tweenCount + 1
        end
        local particleCount = 0
        for _,_ in pairs(Particles) do
            particleCount = particleCount + 1
        end
        local entityCount = 0
        for _,_ in pairs(Alive) do
            entityCount = entityCount + 1
        end
        love.graphics.print("Tweens: " .. tweenCount, 10, 30)
        love.graphics.print("Particles: " .. particleCount, 10, 45)
        love.graphics.print("Entities: " .. entityCount, 10, 60)

        if debug.SHOW_ENTITY_PROPERTIES or debug.LIST_ENTITIES then
            local i = 0
            for _, ent in pairs(Alive) do
                if DEBUG then
                    if debug.LIST_ENTITIES then
                        love.graphics.print(ent.className .. " - " .. ent.id, 10, i*20 + 75)
                    end
                    if debug.SHOW_ENTITY_PROPERTIES then
                        --debug.printTransform(ent.transform)
                        debug.printEntityProperties(ent)
                    end
                end
                i = i + 1
            end
        end
    end

    if GameActive == false then
        love.graphics.setColor(0.1, 0.1, 0.15, 0.9)
        love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)
        love.graphics.setColor(1, 1, 1)

        love.graphics.print("paused.", Screen.w/2, Screen.h/2)
        
        if SHOW_ERRORS then
            love.graphics.setColor(1, 0, 0)
            for i,err in pairs(Errors) do
                love.graphics.print(i .. " - " .. err, 10, (i-1)*13 + 10)
            end
            love.graphics.setColor(0.75, 0.75, 0.75)
            love.graphics.print("'R' to restart", 10, (#Errors+1)*13 + 20)
        end
    end
    
end

function love.keypressed(key)
    if key == "r" then
        love.event.quit("restart")
    end
    if key == "escape" then
        GameActive = not GameActive
    end
    if key == "1" then
        Player:equipNum(1)
    end
    if key == "2" then
        Player:equipNum(2)
    end
    if key == "3" then
        Player:equipNum(3)
    end
    if key == "e" then
        SafeCall(function()
            signals.player.interact:fire()
        end)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        SafeCall(function()
            --signals.player.shoot:fire()
        end)
    end
end

function love.wheelmoved(_, y)
    local zoomFactor = 1.2
    Cam.zoom = math.clamp(
        Cam.zoom * (zoomFactor ^ y),
        0.5,
        2
    )
end

Fonts = {}
function love.load()
    Screen.w = love.graphics.getWidth()
    Screen.h = love.graphics.getHeight()

    Fonts.small = love.graphics.newFont(12)
    Fonts.medium = love.graphics.newFont(24)
    love.graphics.setFont(Fonts.small)

    love.graphics.setDefaultFilter("nearest", "nearest")

    for key, path in pairs(require("lib.sprites")) do
        Sprites[key] = love.graphics.newImage(path)
    end

    local function registerSound(key, path)
        Sounds[key] = love.audio.newSource(path, "static")
        SoundPools[key] = {}
    end
    for key, path in pairs(require("lib.sounds")) do
        if type(path) == "table" then
            Sounds[key] = {}
            for i, path in pairs(path) do
                local newKey = key..i
                registerSound(newKey, path)
                table.insert(Sounds[key], newKey)
            end
        else
            registerSound(key, path)
        end
    end

    for _,func in pairs(LoadFunctions) do
        SafeCall(func)
    end
    waveHandler = require("lib.waveHandler")
end


function love.resize(w, h)
    Screen.w = w
    Screen.h = h
end