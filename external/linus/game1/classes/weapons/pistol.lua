local class = NewClass(require("classes.weaponItem"))
class.className = "pistol"

class.length = 1
class.spriteRecoil = Vec:new(10, 35)

class.sprite = Sprites.pistol

class.shootTick = 0
class.cooldown = 0.5

class.damage = 5
class.recoil = 2

class.bullets = 1
class.spread = 10

return class