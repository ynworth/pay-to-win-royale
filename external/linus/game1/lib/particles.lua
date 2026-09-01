function EmitParticle(particle, pos, vel, params)
    local new = particle:new(pos:clone(), vel and vel:clone(), params)
    Particles[new.id] = new
    return new
end

function EmitParticles(particle, pos, amount, radius, vel, params)
    for i = 1, (amount or 1) do
        EmitParticle(particle, pos:clone():add(Vec:new(math.random()-0.5, math.random()-0.5):mul(radius or 5)), vel, params)
    end
end

function EmitAllParticles(particle, pos, radius, vel, params)
    for _, sprite in pairs(particle.sprites) do
        local particle = EmitParticle(particle, pos:clone():add(Vec:new(math.random()-0.5, math.random()-0.5):mul(radius or 5)), vel, params)
        particle.sprite = sprite
    end
end