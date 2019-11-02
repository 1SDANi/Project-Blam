extends "Projectile.gd"

func on_spawn():
	fInitialVelocity = 27 * 1.5
	fDamage = 25
	fCrit = 35
	fRadius = 0.75
	fAccelerateDuration = 1
	fAcceleration = -27 / fAccelerateDuration
	fAccelerateTime = 0
	after_spawn()