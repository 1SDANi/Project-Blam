extends "Projectile.gd"

func on_spawn():
	fInitialVelocity = 27 * 1
	fDamage = 20
	fCrit = 35
	fRadius = 1
	after_spawn()