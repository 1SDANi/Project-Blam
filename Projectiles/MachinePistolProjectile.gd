extends "Projectile.gd"

func on_spawn():
	fInitialVelocity = 1.5 * Constants.fProjectileSpeedMultiplier
	fDamage = 25.0
	fCrit = 35.0
	fRadius = 0.75
	fAccelerateDuration = 1.0
	fAcceleration = -Constants.fPlayerMaxSpeed / fAccelerateDuration
	fAccelerateTime = 0.0
	after_spawn()