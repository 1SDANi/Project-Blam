extends Area
class_name Projectile

export (NodePath) var pCollider : NodePath
export (NodePath) var pMesh : NodePath
var nCollider : CollisionShape
var nMesh : MeshInstance
var nOwner : Entity
var vVelocity : Vector3
var fInitialVelocity : float = 0.5
var fAccelerateDuration : float = 0.0
var fAcceleration : float = 0.0
var fAccelerateTime : float = -1
var fDamage : float = 20
var fCrit : float = 35
var bDamageIsPercent : bool = false
var bCritIsPercent : bool = false
var fRadius : float = 1
var fLife : float = 10

func _ready():
	vVelocity = Vector3.ZERO
	nCollider = get_node(pCollider)
	nMesh = get_node(pMesh)
	connect("body_entered", self, "_on_body_entered")
	
func on_spawn():
	after_spawn()
	
func after_spawn():
	vVelocity = get_trajectory() * fInitialVelocity
	nCollider.get_shape().set_radius(fRadius)
	nMesh.get_mesh().set_radius(fRadius)
	nMesh.get_mesh().set_height(fRadius * 2)

func _physics_process(delta : float):
	if (fAccelerateTime >= 0 and fAccelerateTime < fAccelerateDuration):
		
		
		if fAccelerateTime + delta < fAccelerateDuration:
			vVelocity += get_trajectory() * fAcceleration * delta
			fAccelerateTime += delta
		else:
			vVelocity += get_trajectory() * fAcceleration * (fAccelerateDuration - fAccelerateTime)
			fAccelerateTime = fAccelerateDuration
	set_translation(get_translation() + transform.basis.xform(vVelocity) * delta)
	fLife -= delta
	if fLife <= 0:
		queue_free()
		
func _on_body_entered(body):
	if body is Entity and body != nOwner:
		if body.bHasWeakpoint and overlaps_area(body.nWeakpoint):
			body.damage(fCrit, bCritIsPercent)
		else:
			body.damage(fDamage, bDamageIsPercent)
		queue_free()
	
func get_trajectory():
	return Vector3.FORWARD.normalized()