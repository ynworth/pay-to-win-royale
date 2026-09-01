local drawer = require("lib.drawer")
local signals = require("lib.signals")

local class = NewClass(require("classes.entity"))
class.className = "player"
class.layer = Layers.player
class.affectedLayers = {
    [2] = true,
    [4] = true
}

class.sprite = Sprites.player
class.speed = 0.8
class.friction = 0.85

function class:constructor(id)
    class._base.constructor(self, true, nil, true)
    self.transform.moveVec = Vec:new(1, 0)
    self.lookVec = Vec:new()
    self.id = id

    self.maxHealth = 100
    self.health = self.maxHealth

    self.coins = 0

    self.damageTick = 0

    self.stepSound = false

    self.interacting = false

    self.weapon = require("classes.weapon"):new("weapon", self)
    self.items = {
        require("classes.weapons.pistol"):new(),
        require("classes.weapons.shotgun"):new(),
        require("classes.weapons.smg"):new(),
    }
    self:setItem(self.items[1])

    self.offset = require("classes.transform"):new(
        Vec:new(),  --pos
        0,          --hasRot
        nil,        --scale
        nil         --hasVel
    )

    signals.player.shoot:connect(function()
        --Cam:screenshake(1.5)
        self.transform.vel:add(self.lookVec:clone():mul(-self.item.recoil))

        for i = 1, self.item.bullets do
            local rot = (self.transform.rot + (math.random()-0.5)*self.item.spread) % 360
            local lookVec = Vec:new():applyDeg(rot)

            local bullet = require("classes.bullet"):new(self.item.damage)
            bullet.transform:set(self.transform.pos:clone():add(lookVec:clone():mul(SPRITE_SCALE*0.5)), rot)
            bullet.lookVec = lookVec
            AddAlive(bullet)
        end
        
    end)

    signals.player.interact:connect(function()
        if self.interacting then
            self.interacting:interact()
        end
    end)
end

function class:setItem(item)
    self.item = item
    self.weapon.sprite = item.sprite
end

function class:equipNum(num)
    local item = self.items[num]
    if item == nil then return end
    self:setItem(item)
end

function class:damage(amount, lookVec, killer)
    self.health = math.clamp(self.health - amount, 0, 100)

    self.damageTick = love.timer.getTime()

    PlaySound("damage", 2, 0.2, 0.7)
    Cam:screenshake(8, 2)

    self.opacity = 0.2
    Task.delay(0.1, function()
        self.opacity = 1
    end)

    self.transform.vel:add(lookVec:clone():mul(10))

    if self.health <= 0 then
        self:remove()
        if killer then
            Cam.target = killer.transform
        end
    end
end

function class:getMoveVec()
    local moveVec = Vec:new(0, 0)
    if love.keyboard.isDown("a") then
        moveVec.x = -1
    end
    if love.keyboard.isDown("d") then
        moveVec.x = 1
    end
    if love.keyboard.isDown("w") then
        moveVec.y = -1
    end
    if love.keyboard.isDown("s") then
        moveVec.y = 1
    end
    return moveVec
end

function class:step()
    PlaySound("step", 0.9, 0.2, 0.5)
    self.stepSound = not self.stepSound
end

function class:tick(t)
    class._base.tick(self)

    if love.mouse.isDown(1) and self.item:canUse() then
        self.item:shoot()
        signals.player.shoot:fire()
        PlaySound("shoot", 1, 0.15, 0.7)
    end

    if self.collisions then
        self.interacting = nil
        for _, entity in pairs(self.collisions) do
            if entity.tags and entity.tags.interactible then
                self.interacting = entity
                break
            end
        end
    end

    self.transform.moveVec = self:getMoveVec()

    local mouseWorldPos = GetMouseWorldPos(1)
    self.lookVec = self.transform.pos:getLookVec(mouseWorldPos)
    self.transform.rot = self.lookVec:angleDeg()

    self.weapon.lookVec:lerp(self.lookVec, 0.5)
    self.weapon.transform.rot = math.lerpAngle(self.weapon.transform.rot, self.transform.rot, 0.8)

    self.transform.vel:add(self.transform.moveVec:clone():mul(self.speed))
    self.transform.vel:mul(self.friction)

    self.transform.pos:add(self.transform.vel:clone())

    if not self.transform.moveVec:isZero() then
        self.offset.pos.y = -math.abs(math.sin(t*13)*7)
        local c = math.cos(t*13)
        self.offset.rot = c*15

        if c > 0.9 and self.stepSound == true then
            self:step()
        elseif c < -0.9 and self.stepSound == false then
            self:step()
        end
    else
        self.offset.pos:lerp(Vec:new(0, -math.abs(math.sin(t*2.5)*3)), 0.4)
        self.offset.rot = math.lerpAngle(self.offset.rot, math.cos(t*2.5)*3, 0.2)
    end

    self.weapon:tick(t)
end

function class:postTick(t)
    self.offset:tick(t)
    self.weapon.transform:tick(t)
    self.weapon:postTick(t)
end

function class:drawSelf(d)
    class._base.draw(self, d, self.offset)
end
function class:drawHeld(d, posA, posB, rotA)
    local lookDir = Vec:new():applyDeg(rotA)
    local rightDir = Vec:new():applyDeg((rotA+90) % 360)
    local offset = lookDir:mul(SPRITE_SCALE)
    local offset2 = Vec:new(0, 0):add(rightDir:clone():mul(4):mul((self.transform.rot+90)%360 > 180 and 1 or -1))
    
    drawer.drawLine(posB, posA:sub(offset2), 2)

    self.weapon:draw(d, self.weapon.offset, offset:sub(offset2))
end

function class:draw(d)

    local posA, rotA, _ = self.weapon:getSpritePos(d, self.weapon.offset)
    local posB, _, _ = self:getSpritePos(d, self.offset)

    local target = Alive.Exit
    if target then
        local fPos1, _, _ = self:getSpritePos(d)
        local fPos2, _, _ = target:getSpritePos(d)

        local t = love.timer.getTime()

        local lookVec = fPos1:getLookVec(fPos2)
        drawer.drawSprite(
            Sprites.arrow, 
            fPos1:add(Vec:new(0, SPRITE_SCALE*0.75)), 
            lookVec:angleDeg(), 
            1
        )
    end

    if (self.transform.rot)%360 < 180 then
        self:drawSelf(d)
        self:drawHeld(d, posA, posB, rotA)
    else
        self:drawHeld(d, posA, posB, rotA)
        self:drawSelf(d)
    end
    
end

return class