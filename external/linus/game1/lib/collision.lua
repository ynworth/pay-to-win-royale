--copyright mr ChatGPT 2026, no rights reserved

Layers = {}
Layers.player = 1
Layers.enemy = 2
Layers.projectile = 3
Layers.interactible = 4
Layers.collectible = 5

local CELL_SIZE = SPRITE_SCALE * 2

Spatial = {
    cells = {}
}

local checked = {}

local function cellKey(x, y)
    return x .. ":" .. y
end

local function toCell(x)
    return math.floor(x / CELL_SIZE)
end

-- reset spatial grid
function Spatial:clear()
    self.cells = {}
end

-- insert entity into grid
function Spatial:insert(entity)
    if not entity.layer then return end

    local size = SPRITE_SCALE * entity.transform.scale
    local half = size / 2

    local x = entity.transform.pos.x
    local y = entity.transform.pos.y

    local minX = toCell(x - half)
    local maxX = toCell(x + half)
    local minY = toCell(y - half)
    local maxY = toCell(y + half)

    for cx = minX, maxX do
        for cy = minY, maxY do
            local key = cellKey(cx, cy)
            local cell = self.cells[key]

            if not cell then
                cell = {}
                self.cells[key] = cell
            end

            cell[#cell + 1] = entity
        end
    end
end

-- AABB collision (center-based)
function AABB(a, b)
    local sizeA = SPRITE_SCALE * a.transform.scale
    local sizeB = SPRITE_SCALE * b.transform.scale

    local halfA = sizeA * 0.5
    local halfB = sizeB * 0.5

    return math.abs(a.transform.pos.x - b.transform.pos.x) < (halfA + halfB)
       and math.abs(a.transform.pos.y - b.transform.pos.y) < (halfA + halfB)
end

-- layer filter
function shouldCollide(a, b)
    return a.affectedLayers
       and b.layer
       and a.affectedLayers[b.layer]
end

-- register collision once
function registerCollision(a, b)
    a.collisions = a.collisions or {}
    b.collisions = b.collisions or {}

    a.collisions[#a.collisions + 1] = b
    b.collisions[#b.collisions + 1] = a
end

-- build spatial grid
function BuildSpatial()
    Spatial:clear()

    for _, entity in pairs(Alive) do
        Spatial:insert(entity)
    end
end

-- reset per-frame collision cache
local function resetCollisionCache()
    checked = {}
end

local function markChecked(a, b)
    checked[a] = checked[a] or {}
    checked[a][b] = true
end

local function isChecked(a, b)
    return checked[a] and checked[a][b]
end

-- main collision function
function CheckAllCollisions()
    BuildSpatial()
    resetCollisionCache()

    -- clear old collisions
    for _, e in pairs(Alive) do
        e.collisions = nil
    end

    for _, cell in pairs(Spatial.cells) do
        for i = 1, #cell do
            local a = cell[i]

            for j = i + 1, #cell do
                local b = cell[j]

                if a.layer and b.layer then
                    if shouldCollide(a, b) or shouldCollide(b, a) then

                        if not isChecked(a, b) then
                            markChecked(a, b)

                            if AABB(a, b) then
                                registerCollision(a, b)
                            end
                        end

                    end
                end
            end
        end
    end
end