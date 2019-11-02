extends Spatial

const fGravity : float = 0.98
const fMaxLook : float = PI / 2 - PI / 8
const fMaxRotate : float = PI * 2 * 0.05
const BattleRifle = preload("Guns/BattleRifle.gd")
const MachinePistol = preload("Guns/MachinePistol.gd")
const GenericProjectile = preload("Projectiles/Projectile.tscn")
const BattleRifleProjectile = preload("Projectiles/BattleRifleProjectile.tscn")
const MachinePistolProjectile = preload("Projectiles/MachinePistolProjectile.tscn")
# 36 is the player's max ground speed
const fSpeedReference : float = 36.0
const fProjectileSpeedMultiplier : float = 1.1 * fSpeedReference