require("lib.globalUtil")

Sprites = {}
Sounds = {}
SoundPools = {}

Alive = {}
ScheduledAlive = {}
Tweens = {}
Particles = {}
DelayedFuncs = {}

Vec =     require("classes.global.vector")
Color =   require("classes.global.color")
Tween =   require("classes.global.tween")
Signal =  require("classes.global.signal")

require("lib.collision")
require("lib.errorHandler")
require("lib.soundHandler")
require("lib.particles")
require("lib.task")

Screen = {
    w = 0,
    h = 0
}

FAR_DISTANCE = SPRITE_SCALE*50

LoadFunctions = {}

function LoadFunctions.init()
    Cam = require("classes.camera"):new("camera")
    Player = require("classes.player"):new("player")

    Cam.target = Player.transform

    AddAlive(Player)


    local dummy = require("classes.entity"):new()

    --AddAlive(dummy)


    local dummy = require("classes.medkitMachine"):new()
    dummy.id = "Test"
    dummy.transform:set(Vec:new(100, 0))
    AddAlive(dummy)

    --local dummy = require("classes.exit"):new()
    --dummy.id = "Exit"
    --dummy.transform:set(Vec:new(0, -64))
    --AddAlive(dummy)

    --Cam.target = dummy.transform

    
end
