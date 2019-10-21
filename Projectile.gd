extends Area

const Entity = preload("Entity.gd")
export (NodePath) var pCollider : NodePath
export (NodePath) var pMesh : NodePath
var cCollision : KinematicCollision
var nCollider : CollisionShape
var nMesh : MeshInstance
var vVelocity : Vector3
var fInitialVelocity : float = 0.5
var fAcceleration : float = 0
var fDamage : float = 10
var fRadius : float = 1
var fLife : float = 10

func _ready():
	vVelocity = Vector3.ZERO
	nCollider = get_node(pCollider)
	nMesh = get_node(pMesh)
	connect("body_entered", self, "_on_body_entered")
	
func on_spawn():
	vVelocity = get_trajectory() * fInitialVelocity
	nCollider.get_shape().set_radius(fRadius)
	nMesh.get_mesh().set_radius(fRadius)
	nMesh.get_mesh().set_height(fRadius * 2)

func _physics_process(delta : float):
	vVelocity += get_trajectory() * fAcceleration
	set_translation(get_translation() + transform.basis.xform(vVelocity))
	fLife -= delta
	if fLife <= 0:
		queue_free()
		
func _on_body_entered(body):
	if body is Entity:
		body.damage(fDamage)
	queue_free()
	
func get_trajectory():
	return Vector3.FORWARD.normalized()