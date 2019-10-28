extends "GunItem.gd"

func _init(weilder).(weilder):
	._init(weilder)
	iClip = 3
	fCooldown = 0.1
	fRecharge = 5.0
	fMaxHoldTime = 0.0
	sProjectile = preload("../Projectiles/MachinePistolProjectile.tscn")