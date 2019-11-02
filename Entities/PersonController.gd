extends "Entity.gd"
class_name MachinePistol

var nLook : Node
var nHands : Node
export (float) var fRotateSpeed : float = 0.05
export (float) var fJumpStrength: float 
export (NodePath) var pLook : NodePath
export (NodePath) var pHands : NodePath
export (float) var fGroundSpeed: float 
export (float) var fAirSpeed: float 
var vMoveLook : Vector2 = Vector2.ZERO
var vMotion : Vector3 = Vector3.ZERO
var oBattleRifle = Constants.BattleRifle
var oMachinePistol = Constants.MachinePistol
var oPrimaryWeapon
var oSecondaryWeapon

func _ready():
	nLook = get_node(pLook)
	nHands = get_node(pHands)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	oPrimaryWeapon = oBattleRifle.new(self)
	oSecondaryWeapon = oMachinePistol.new(self)
	bHasWeakpoint = true

func _physics_process(delta : float):
	move_camera(delta)
	apply_movement()
	oPrimaryWeapon.process(delta)
	oSecondaryWeapon.process(delta)
	
func jump():
	vVelocity.y += fJumpStrength
	
func swap_weapons():
	var oNewPrimary = oSecondaryWeapon
	oSecondaryWeapon = oPrimaryWeapon
	oPrimaryWeapon = oNewPrimary
	oSecondaryWeapon.trigger_up()
	
func apply_movement():
	if isGrounded():
		vVelocity += fGroundSpeed * transform.basis.xform(vMotion).normalized()
	else:
		vVelocity += fAirSpeed * transform.basis.xform(vMotion).normalized()
	vMotion = Vector3.ZERO
	
func move_camera(delta : float):
	var fMoveMod : float = PI * 2 * fRotateSpeed * delta
	rotate_y(min(fMoveMod * vMoveLook.x, Constants.fMaxRotate))
	nLook.rotate_x(min(fMoveMod * vMoveLook.y, Constants.fMaxRotate))
	vMoveLook = Vector2.ZERO
	var vRotation : Vector3 = nLook.get_rotation()
	vRotation.x = clamp(vRotation.x, -Constants.fMaxLook, Constants.fMaxLook)
	nLook.set_rotation(vRotation)
	vMoveLook = Vector2.ZERO