var sProjectile
var nWorld : Node
var nWeilder : Node
var fMaxHoldTime : float = 0
var fCooldown : float = 1
var fRecharge : float = 2
var fTriggerHeld : float
var fWaiting : float
var iClip : int
var iCharge : int


func _init(weilder):
	iCharge = iClip
	nWeilder = weilder
	nWorld = weilder.nWorld
	fWaiting = 0
	fTriggerHeld = -1
	sProjectile = preload("../Projectiles/Projectile.tscn")
	
func process(delta : float):
	if fWaiting >= fRecharge:
		iCharge = iClip
	if fWaiting >= fCooldown:
		if fTriggerHeld >= 0:
			shoot()
	fWaiting += delta
	if fTriggerHeld >= 0 and fMaxHoldTime > 0:
		fTriggerHeld += delta
	
func trigger_down():
	fTriggerHeld = 0
	
func trigger_up():
	fTriggerHeld = -1
	
func shoot():
	if not iCharge > 0: return
	iCharge -= 1
	fWaiting = 0
	var nProjectile = sProjectile.instance()
	nWorld.add_child(nProjectile)
	nProjectile.set_rotation(nWeilder.get_rotation() + nWeilder.nLook.get_rotation())
	nProjectile.on_spawn()
	nProjectile.set_translation(nWeilder.nHands.get_global_transform().origin + nWeilder.get_rotation().normalized() * nProjectile.nCollider.get_shape().get_radius())
	nProjectile.nOwner = nWeilder