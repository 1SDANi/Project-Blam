extends "GunItem.gd"

func _init(weilder).(weilder):
	._init(weilder)
	iClip = 5
	fCooldown = 1.0
	fRecharge = 2.0
	fMaxHoldTime = 0.0
	sProjectile = preload("../Projectiles/BattleRifleProjectile.tscn")