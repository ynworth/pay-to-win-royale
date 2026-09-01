local class = NewClass(require("classes.weaponItem"))
class.className = "smg"

class.length = 1.5
class.spriteRecoil = Vec:new(6, 10)

class.sprite = Sprites.smg

class.shootTick = 0
class.cooldown = 0.1

class.damage = 3
class.recoil = 1

class.bullets = 1
class.spread = 20

return class