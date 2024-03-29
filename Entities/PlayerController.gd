extends "PersonController.gd"
var sJump : String = "ui_select"
var sForward : String = "ui_up"
var sBack : String = "ui_down"
var sLeft : String = "ui_left"
var sRight : String = "ui_right"
var sShoot : String = "game_shoot"
var sLookUp : String = "game_look_up"
var sLookDown : String = "game_look_down"
var sLookLeft : String = "game_look_left"
var sLookRight : String = "game_look_right"
var sEscape : String = "ui_end"
var sSwapWeapons : String = "game_swap_weapon"
var fLastTrigger : float

func _input(event):
	if (event.is_action_pressed(sEscape)):
		get_tree().quit()
	
	if event is InputEventMouseButton or event is InputEventJoypadMotion:
		if event.get_action_strength(sShoot) == 1 and fLastTrigger != 1:
			oPrimaryWeapon.trigger_down()
		if event.get_action_strength(sShoot) == 0 and fLastTrigger != 0:
			oPrimaryWeapon.trigger_up()
		fLastTrigger = event.get_action_strength(sShoot)
	
	if event is InputEventMouseMotion:
		vMoveLook.x += -event.get_relative().x
		vMoveLook.y += -event.get_relative().y
	
	if event is InputEventKey or event is InputEventJoypadButton:
		if event.is_action_pressed(sJump):
			if isGrounded():
				jump()
				fCoyoteTimer = 0
				
		if event.is_action_pressed(sSwapWeapons):
			swap_weapons()
			if Input.get_action_strength(sShoot) == 1:
				oPrimaryWeapon.trigger_down()
				
func _physics_process(delta):
	vMotion.x += Input.get_action_strength(sRight) - Input.get_action_strength(sLeft)
	vMotion.z += Input.get_action_strength(sBack) - Input.get_action_strength(sForward)
	
	vMoveLook.x += (Input.get_action_strength(sLookLeft) - Input.get_action_strength(sLookRight)) * 10
	vMoveLook.y += (Input.get_action_strength(sLookUp) - Input.get_action_strength(sLookDown)) * 10
	