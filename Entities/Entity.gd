extends KinematicBody
class_name Entity

var nWorld : Node
export (float) var fCoyoteTime : float = 0.25
export (float) var fMass : float = 1
export (float) var fGroundFriction: float 
export (float) var fAirFriction: float 
var vVelocity : Vector3 = Vector3.ZERO
var fCoyoteTimer : float
var fHealth : float
var fMaxHealth : float = 100
var bHasWeakpoint : bool = false
export (NodePath) var pWeakpoint : NodePath
var nWeakpoint : Weakpoint

func _ready():
	fHealth = fMaxHealth
	nWeakpoint = get_node(pWeakpoint)
	nWorld = get_node("/root/World")
	
func _physics_process(delta : float):
	apply_friction()
	move_entity(delta)

func apply_friction():
	vVelocity.y -= Constants.fGravity * fMass
	if vVelocity != Vector3.ZERO:
		var fFriction : float = fGroundFriction if isGrounded() else fAirFriction
		vVelocity.x -= vVelocity.x * fFriction
		vVelocity.z -= vVelocity.z * fFriction
	if abs(vVelocity.length()) < 0.005:
		vVelocity = Vector3.ZERO

func move_entity(delta : float):
	vVelocity = move_and_slide(vVelocity, Vector3.UP, true, 4)
	if is_on_floor():
		if fCoyoteTimer != fCoyoteTime:
			fCoyoteTimer = fCoyoteTime
	elif fCoyoteTimer > 0:
		fCoyoteTimer = max(fCoyoteTimer - delta, 0)
	
func damage(fDamage: float, bPercent : bool = false):
	fHealth -= (fHealth / 100 * fDamage) if bPercent else fDamage
	print(fHealth)
	if fHealth <= 0:
		queue_free()
	
func isGrounded(): 
	return fCoyoteTimer > 0