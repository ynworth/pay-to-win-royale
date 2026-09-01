local class = NewClass(require("classes.weaponItem"))
class.className = "shotgun"

class.length = 1.5
class.spriteRecoil = Vec:new(12, 70)

class.sprite = Sprites.shotgun

class.shootTick = 0
class.cooldown = 1

class.damage = 3
class.recoil = 10

class.bullets = 6
class.spread = 45

return class