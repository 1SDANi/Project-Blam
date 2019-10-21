extends "PersonController.gd"

export (NodePath) var pTarget : NodePath
var nTarget : Node

func _ready():
	nTarget = get_node(pTarget)

func _physics_process(delta):
	var vRotation = get_rotation()
	var vTargetPosition = nTarget.get_global_transform().origin
	look_at(vTargetPosition, Vector3.UP)
	var vTargetRotation = get_rotation()
	vTargetRotation.x = vRotation.x
	vTargetRotation.z = vRotation.z
	vTargetRotation.y = lerp_angle(vRotation.y, vTargetRotation.y, delta * 5)
	set_rotation(vTargetRotation)
	
func lerp_angle(from, to, weight):
    return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
    var max_angle = PI * 2
    var difference = fmod(to - from, max_angle)
    return fmod(2 * difference, max_angle) - difference