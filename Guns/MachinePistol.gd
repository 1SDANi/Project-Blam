extends "GunItem.gd"

func _init(weilder).(weilder):
	._init(weilder)
	iClip = 3
	fCooldown = 0.1
	fRecharge = 3.0
	fMaxHoldTime = 0.0
	sProjectile = Constants.MachinePistolProjectile