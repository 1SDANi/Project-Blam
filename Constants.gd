extends Spatial

const fGravity = 0.98
const fMaxLook : float = PI / 2 - PI / 8
const fMaxRotate : float = PI * 2 * 0.05
const BattleRifle = preload("Guns/BattleRifle.gd")
const MachinePistol = preload("Guns/MachinePistol.gd")
const GenericProjectile = preload("Projectiles/Projectile.tscn")
const BattleRifleProjectile = preload("Projectiles/BattleRifleProjectile.tscn")
const MachinePistolProjectile = preload("Projectiles/MachinePistolProjectile.tscn")