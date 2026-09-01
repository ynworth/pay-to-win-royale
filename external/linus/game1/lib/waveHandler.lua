local waveHandler = {}

waveHandler.spawnTick = 0
waveHandler.pool = {
    require("classes.enemies.walker"),
    require("classes.enemies.charger"),
}

function waveHandler:tick(t)
    if waveHandler.spawnTick > t then
        return
    end
    if Player.health <= 0 then return end
    waveHandler.spawnTick = t+3
    for i = 1, 2 do
        local dummy = waveHandler.pool[math.random(1, #waveHandler.pool)]:new()
        dummy.transform:set(GetSpawn(Player.transform.pos, FAR_DISTANCE))
        AddAlive(dummy)
    end
end

return waveHandler