extends "Projectile.gd"

func on_spawn():
	fInitialVelocity = 1 * Constants.fProjectileSpeedMultiplier
	fDamage = 20
	fCrit = 35
	fRadius = 1
	after_spawn()