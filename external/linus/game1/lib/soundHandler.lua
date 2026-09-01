local masterVolume = 0.5

function PlaySound(name, pitch, pitchVariation, volume)
    local snd = Sounds[name]
    if type(snd) == "table" then
        name = snd[math.random(1, #snd)]
        snd = Sounds[name]
    end
    local pool = SoundPools[name]

    local function play(s)
        s:setPitch((pitch or 1) + ((math.random()-0.5) * (pitchVariation or 0)))
        s:setVolume((volume or 1) * masterVolume)
        s:play()
    end

    -- reuse available instance from SAME sound type
    for _, s in ipairs(pool) do
        if not s:isPlaying() then
            play(s)
            return
        end
    end

    -- none available → create new clone
    local s = snd:clone()
    table.insert(pool, s)

    play(s)
end