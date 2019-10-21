GDPC                                                                                L   res://.import/checkerboard.png-5009a21f89b8fece52b4f5160c9736ac.s3tc.stex   �?             %��$; �!�κ`�<   res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stexPF      �      �p��<f��r�g��.�   res://Entity.gd �      �      �󔈬+;�١U"A'[   res://PersonController.gd   �	      i      N��h��]�$��~$T   res://PlayerController.gd                �ĕ��Y����x�A�   res://Projectile.gd @      9      U���s����-b	�   res://Projectile.tscn   �      &      ��bgax�ח9�DdQ   res://Target.tscn   �!      �      fF""��EL�<��   res://TurretController.gd   �%      �      ����8���Li_G.I   res://World.gd  �(      �       �L���dz?[�x���G   res://World.tscnP)      �      'U�r�<d-��R�T    res://checkerboard.png.import   @      v      �)c���v܃	���:   res://checkerboard_blue.tres�C      �       xY7���7��hr��_    res://checkerboard_green.tres   �D            A*�+�FH����^`�   res://default_env.tres  �E      �       um�`�N��<*ỳ�8   res://icon.png  pV      i      ����󈘥Ey��
�   res://icon.png.import   �S      �      �����%��(#AB�   res://project.binary�c      �      Z�=��@��%8H��l�    extends KinematicBody

export (float) var fCoyoteTime : float = 0.25
var nWorld : Node
export (NodePath) var pWorld : NodePath
export (float) var fMass : float = 1
export (float) var fGroundFriction: float 
export (float) var fAirFriction: float 
var vVelocity : Vector3 = Vector3.ZERO
var fCoyoteTimer : float
var fHealth : float

func _ready():
	nWorld = get_node(pWorld)
	fHealth = 100
	
func _physics_process(delta : float):
	apply_friction()
	move_entity(delta)

func apply_friction():
	vVelocity.y -= nWorld.fGravity * fMass
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
	fHealth -= fHealth / 100 * fDamage if bPercent else fDamage
	if fHealth <= 0:
		queue_free()
	
func isGrounded(): 
	return fCoyoteTimer > 0     extends "Entity.gd"

var sProjectile = preload("Projectile.tscn")
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

func _ready():
	nLook = get_node(pLook)
	nHands = get_node(pHands)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta : float):
	move_camera(delta)
	apply_movement()
	
func shoot():
	var nProjectile = sProjectile.instance()
	nWorld.add_child(nProjectile)
	nProjectile.fRadius = 0.25
	nProjectile.set_rotation(get_rotation() + nLook.get_rotation())
	nProjectile.on_spawn()
	nProjectile.set_translation(nHands.get_global_transform().origin + get_rotation().normalized() * nProjectile.nCollider.get_shape().get_radius())
	
func jump():
	vVelocity.y += fJumpStrength
	
func apply_movement():
	if isGrounded():
		vVelocity += fGroundSpeed * transform.basis.xform(vMotion).normalized()
	else:
		vVelocity += fAirSpeed * transform.basis.xform(vMotion).normalized()
	vMotion = Vector3.ZERO
	
func move_camera(delta : float):
	var fMoveMod : float = PI * 2 * fRotateSpeed * delta
	rotate_y(min(fMoveMod * vMoveLook.x, nWorld.fMaxRotate))
	nLook.rotate_x(min(fMoveMod * vMoveLook.y, nWorld.fMaxRotate))
	vMoveLook = Vector2.ZERO
	var vRotation : Vector3 = nLook.get_rotation()
	vRotation.x = clamp(vRotation.x, -nWorld.fMaxLook, nWorld.fMaxLook)
	nLook.set_rotation(vRotation)
	vMoveLook = Vector2.ZERO       extends "PersonController.gd"
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



func _input(event):
	if (event.is_action_pressed(sEscape)):
		get_tree().quit()
	
	if event is InputEventMouseButton or event is InputEventJoypadMotion:
		if event.get_action_strength(sShoot) == 1:
			shoot()
	
	if event is InputEventMouseMotion:
		vMoveLook.x += -event.get_relative().x
		vMoveLook.y += -event.get_relative().y
	
	if event is InputEventKey or event is InputEventJoypadButton:
		if event.is_action_pressed(sJump):
			if isGrounded():
				jump()
				fCoyoteTimer = 0
				
func _physics_process(delta):
	vMotion.x += Input.get_action_strength(sRight) - Input.get_action_strength(sLeft)
	vMotion.z += Input.get_action_strength(sBack) - Input.get_action_strength(sForward)
	
	vMoveLook.x += (Input.get_action_strength(sLookLeft) - Input.get_action_strength(sLookRight)) * 10
	vMoveLook.y += (Input.get_action_strength(sLookUp) - Input.get_action_strength(sLookDown)) * 10  extends Area

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
	return Vector3.FORWARD.normalized()       [gd_scene load_steps=13 format=2]

[ext_resource path="res://Projectile.gd" type="Script" id=1]

[sub_resource type="OpenSimplexNoise" id=1]
octaves = 6
period = 175.0
persistence = 0.75
lacunarity = 1.5

[sub_resource type="NoiseTexture" id=2]
seamless = true
noise = SubResource( 1 )

[sub_resource type="OpenSimplexNoise" id=3]
period = 50.0
persistence = 0.75
lacunarity = 1.75

[sub_resource type="NoiseTexture" id=4]
noise = SubResource( 3 )

[sub_resource type="OpenSimplexNoise" id=5]
octaves = 1
period = 75.0
persistence = 0.6
lacunarity = 1.75

[sub_resource type="NoiseTexture" id=6]
seamless = true
noise = SubResource( 5 )

[sub_resource type="OpenSimplexNoise" id=7]
period = 75.0
persistence = 0.75
lacunarity = 2.25

[sub_resource type="NoiseTexture" id=8]
seamless = true
noise = SubResource( 7 )

[sub_resource type="SpatialMaterial" id=9]
flags_transparent = true
params_diffuse_mode = 3
params_specular_mode = 2
albedo_color = Color( 1, 0, 0, 0.752941 )
albedo_texture = SubResource( 2 )
metallic = 0.5
roughness = 0.25
emission_enabled = true
emission = Color( 1, 0, 0, 1 )
emission_energy = 0.5
emission_operator = 0
emission_on_uv2 = false
normal_enabled = true
normal_scale = 0.75
normal_texture = SubResource( 8 )
ao_enabled = true
ao_light_affect = 0.0
ao_texture = SubResource( 4 )
ao_on_uv2 = false
ao_texture_channel = 0
depth_enabled = true
depth_scale = 1.0
depth_deep_parallax = false
depth_flip_tangent = true
depth_flip_binormal = true
depth_texture = SubResource( 6 )
subsurf_scatter_enabled = true
subsurf_scatter_strength = 1.0

[sub_resource type="SphereMesh" id=10]
material = SubResource( 9 )

[sub_resource type="SphereShape" id=11]

[node name="Projectile" type="Area"]
gravity_vec = Vector3( 0, 0, 0 )
gravity = 0.0
linear_damp = 0.0
angular_damp = 0.0
script = ExtResource( 1 )
pCollider = NodePath("CollisionShape")
pMesh = NodePath("MeshInstance")

[node name="MeshInstance" type="MeshInstance" parent="."]
mesh = SubResource( 10 )
material/0 = null

[node name="CollisionShape" type="CollisionShape" parent="."]
shape = SubResource( 11 )
          [gd_scene load_steps=5 format=2]

[ext_resource path="res://PersonController.gd" type="Script" id=1]

[sub_resource type="CylinderMesh" id=1]

[sub_resource type="CylinderShape" id=2]

[sub_resource type="BoxShape" id=3]

[node name="Target" type="KinematicBody"]
script = ExtResource( 1 )
fGroundFriction = 1.0
fAirFriction = 1.0
fRotateSpeed = 0.0
pLook = NodePath("Look")

[node name="MeshInstance" type="MeshInstance" parent="."]
transform = Transform( 1, 0, 0, 0, -1.09278e-008, -1, 0, 0.25, -4.37114e-008, 0, 0, 0 )
mesh = SubResource( 1 )
material/0 = null

[node name="CollisionShape" type="CollisionShape" parent="."]
transform = Transform( 1, 0, 0, 0, -1.09278e-008, -1, 0, 0.25, -4.37114e-008, 0, 0, 0 )
shape = SubResource( 2 )

[node name="CollisionShape2" type="CollisionShape" parent="."]
transform = Transform( 0.5, 0, 0, 0, 0.25, 0, 0, 0, 0.25, 0, -0.75, 0 )
shape = SubResource( 3 )

[node name="Look" type="Spatial" parent="."]
transform = Transform( 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0.5 )
               extends "PersonController.gd"

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
    return fmod(2 * difference, max_angle) - difference     extends Spatial

export(float) var fGravity = 9.8
export (float) var fMaxLook : float = PI / 2
export (float) var fMaxRotate : float = PI * 2 * 0.05            [gd_scene load_steps=15 format=2]

[ext_resource path="res://World.gd" type="Script" id=1]
[ext_resource path="res://PlayerController.gd" type="Script" id=2]
[ext_resource path="res://checkerboard_blue.tres" type="Material" id=3]
[ext_resource path="res://TurretController.gd" type="Script" id=4]
[ext_resource path="res://checkerboard_green.tres" type="Material" id=5]

[sub_resource type="CapsuleShape" id=1]

[sub_resource type="CapsuleMesh" id=2]
material = ExtResource( 3 )

[sub_resource type="ProceduralSky" id=3]
sky_top_color = Color( 0.839216, 0.917647, 0.980392, 1 )
sky_horizon_color = Color( 0.647059, 0.839216, 0.945098, 1 )
ground_bottom_color = Color( 0.47451, 0.760784, 0.917647, 1 )
ground_horizon_color = Color( 0.647059, 0.839216, 0.945098, 1 )

[sub_resource type="Environment" id=4]
background_mode = 2
background_sky = SubResource( 3 )
fog_enabled = true
auto_exposure_scale = 0.6
ss_reflections_enabled = true
ssao_enabled = true
dof_blur_far_distance = 0.01
dof_blur_far_transition = 4349.81
dof_blur_far_amount = 0.05
dof_blur_far_quality = 2
glow_enabled = true

[sub_resource type="CubeMesh" id=5]
size = Vector3( 2, 4, 2 )

[sub_resource type="BoxShape" id=6]
extents = Vector3( 1, 2, 1 )

[sub_resource type="BoxShape" id=7]
extents = Vector3( 100, 0.125, 100 )

[sub_resource type="BoxShape" id=8]
extents = Vector3( 4, 0.06, 8 )

[sub_resource type="ConvexPolygonShape" id=9]
points = PoolVector3Array( -4, 0.75, 8, -4, 0.75, -8, -4, 0.75, 8, -4, 0.75, -8, -4, -0.75, 8, 4, -0.75, -8, 4, -0.75, 8, -4, -0.75, -8, -4, 0.75, 8, -4, 0.75, -8, -4, 0.75, -8, -4, 0.75, 8, 4, -0.75, 8, -4, -0.75, -8, 4, -0.75, -8, -4, -0.75, 8, -4, -0.75, 8, 4, -0.75, 8, -4, -0.75, -8, 4, -0.75, -8 )

[node name="World" type="Spatial"]
script = ExtResource( 1 )
fGravity = 0.98

[node name="Player" type="KinematicBody" parent="."]
transform = Transform( 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2, 0 )
script = ExtResource( 2 )
pWorld = NodePath("..")
fMass = 1.2
fGroundFriction = 0.1
fAirFriction = 0.1
fJumpStrength = 25.0
pLook = NodePath("Camera")
pHands = NodePath("Camera/Hands")
fGroundSpeed = 3.0
fAirSpeed = 3.0

[node name="Body" type="CollisionShape" parent="Player"]
transform = Transform( 1, 0, 0, 0, -4.37114e-008, -1, 0, 1, -4.37114e-008, 0, 0, 0 )
shape = SubResource( 1 )

[node name="MeshInstance" type="MeshInstance" parent="Player"]
transform = Transform( 1, 0, 0, 0, -4.37114e-008, -1, 0, 1, -4.37114e-008, 0, 0, 0 )
mesh = SubResource( 2 )
material/0 = null

[node name="Camera" type="Camera" parent="Player"]
transform = Transform( 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.75, -1.1 )
environment = SubResource( 4 )

[node name="Hands" type="Spatial" parent="Player/Camera"]
transform = Transform( 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, -0.9 )

[node name="DirectionalLight" type="DirectionalLight" parent="."]
transform = Transform( 1, 0, 0, 0, 0.707107, 0.707107, 0, -0.707107, 0.707107, 0, 0, 0 )
shadow_enabled = true

[node name="CSGCombiner" type="CSGCombiner" parent="."]
use_collision = true

[node name="CenterContainer" type="CenterContainer" parent="."]
anchor_right = 1.0
anchor_bottom = 1.0

[node name="Control" type="Control" parent="CenterContainer"]
margin_left = 512.0
margin_top = 300.0
margin_right = 512.0
margin_bottom = 300.0

[node name="Polygon2D" type="Polygon2D" parent="CenterContainer/Control"]
position = Vector2( 0, -4 )
color = Color( 1, 0, 0, 1 )
polygon = PoolVector2Array( 0, 5, 5, 0, 3, 0, 0, 3 )

[node name="Polygon2D2" type="Polygon2D" parent="CenterContainer/Control"]
position = Vector2( 0, -4 )
rotation = 1.5708
color = Color( 1, 0, 0, 1 )
polygon = PoolVector2Array( 0, 5, 5, 0, 3, 0, 0, 3 )

[node name="Polygon2D3" type="Polygon2D" parent="CenterContainer/Control"]
position = Vector2( 0, -4 )
rotation = 3.14159
color = Color( 1, 0, 0, 1 )
polygon = PoolVector2Array( 0, 5, 5, 0, 3, 0, 0, 3 )

[node name="Polygon2D4" type="Polygon2D" parent="CenterContainer/Control"]
position = Vector2( 0, -4 )
rotation = 4.71239
color = Color( 1, 0, 0, 1 )
polygon = PoolVector2Array( 0, 5, 5, 0, 3, 0, 0, 3 )

[node name="Dummy" type="KinematicBody" parent="."]
transform = Transform( 1, 0, 0, 0, 1, 0, 0, 0, 1, 10, 2.5, 10 )
script = ExtResource( 4 )
pWorld = NodePath("..")
pLook = NodePath("Look")
pHands = NodePath("Look/Hands")
pTarget = NodePath("../Player")

[node name="MeshInstance" type="MeshInstance" parent="Dummy"]
mesh = SubResource( 5 )
material/0 = null

[node name="CollisionShape" type="CollisionShape" parent="Dummy"]
shape = SubResource( 6 )

[node name="Look" type="Spatial" parent="Dummy"]
transform = Transform( 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.75, -1.1 )

[node name="Hands" type="Spatial" parent="Dummy/Look"]
transform = Transform( 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, -0.9 )

[node name="Tween" type="Tween" parent="Dummy"]

[node name="StaticBody" type="StaticBody" parent="."]

[node name="CollisionShape" type="CollisionShape" parent="StaticBody"]
shape = SubResource( 7 )

[node name="CSGBox" type="CSGBox" parent="StaticBody"]
width = 200.0
height = 0.25
depth = 200.0
material = ExtResource( 5 )

[node name="CSGBox2" type="CSGBox" parent="StaticBody"]
transform = Transform( 1, 0, 0, 0, 1, 0, 0, 0, 1, -16, 1, 0 )
width = 8.0
depth = 16.0
material = ExtResource( 5 )

[node name="CSGBox3" type="CSGBox" parent="StaticBody/CSGBox2"]
transform = Transform( 0.984808, 0.173648, 0, -0.173648, 0.984808, 0, 0, 0, 1, 0, 1, 0 )
operation = 2
width = 9.0
depth = 17.0
material = ExtResource( 5 )

[node name="CollisionShape2" type="CollisionShape" parent="StaticBody"]
transform = Transform( 1, 0, 0, 0, 1, 0, 0, 0, 1, -16, 0.19, 0 )
shape = SubResource( 8 )

[node name="CollisionShape3" type="CollisionShape" parent="StaticBody"]
transform = Transform( 1, 0, 0, 0, 1, 0, 0, 0, 1, -16, 1, 0 )
shape = SubResource( 9 )
       GDST           �������    [remap]

importer="texture"
type="StreamTexture"
path.s3tc="res://.import/checkerboard.png-5009a21f89b8fece52b4f5160c9736ac.s3tc.stex"
path.etc2="res://.import/checkerboard.png-5009a21f89b8fece52b4f5160c9736ac.etc2.stex"
metadata={
"imported_formats": [ "s3tc", "etc2" ],
"vram_texture": true
}

[deps]

source_file="res://checkerboard.png"
dest_files=[ "res://.import/checkerboard.png-5009a21f89b8fece52b4f5160c9736ac.s3tc.stex", "res://.import/checkerboard.png-5009a21f89b8fece52b4f5160c9736ac.etc2.stex" ]

[params]

compress/mode=2
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=true
flags/filter=false
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=1
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
stream=false
size_limit=0
detect_3d=false
svg/scale=1.0
          [gd_resource type="SpatialMaterial" load_steps=2 format=2]

[ext_resource path="res://checkerboard.png" type="Texture" id=1]

[resource]
albedo_color = Color( 0, 0.376471, 0.501961, 1 )
albedo_texture = ExtResource( 1 )
uv1_scale = Vector3( 8, 8, 1 )
     [gd_resource type="SpatialMaterial" load_steps=2 format=2]

[ext_resource path="res://checkerboard.png" type="Texture" id=1]

[resource]
albedo_color = Color( 0.376471, 0.501961, 0.376471, 1 )
albedo_texture = ExtResource( 1 )
uv1_scale = Vector3( 8, 8, 1 )
              [gd_resource type="Environment" load_steps=2 format=2]

[sub_resource type="ProceduralSky" id=1]

[resource]
background_mode = 2
background_sky = SubResource( 1 )
             GDST@   @           |  PNG �PNG

   IHDR   @   @   �iq�  ?IDATx��{pTU�����;�N7	�����%"fyN�8��r\]fEgةf���X�g��F�Y@Wp\]|,�D@��	$$���	��I�n���ҝt����JW�s��}�=���|�D(���W@T0^����f��	��q!��!i��7�C���V�P4}! ���t�ŀx��dB.��x^��x�ɏN��贚�E�2�Z�R�EP(�6�<0dYF���}^Ѡ�,	�3=�_<��(P&�
tF3j�Q���Q�B�7�3�D�@�G�U��ĠU=� �M2!*��[�ACT(�&�@0hUO�u��U�O�J��^FT(Qit �V!>%���9 J���jv	�R�@&��g���t�5S��A��R��OO^vz�u�L�2�����lM��>tH
�R6��������dk��=b�K�љ�]�י�F*W�볃�\m=�13� �Є,�ˏy��Ic��&G��k�t�M��/Q]�أ]Q^6o��r�h����Lʳpw���,�,���)��O{�:א=]� :LF�[�*���'/���^�d�Pqw�>>��k��G�g���No���\��r����/���q�̾��	�G��O���t%L�:`Ƶww�+���}��ݾ ۿ��SeŔ����  �b⾻ǰ��<n_�G��/��8�Σ�l]z/3��g����sB��tm�tjvw�:��5���l~�O���v��]ǚ��֩=�H	u���54�:�{"������}k����d���^��`�6�ev�#Q$�ήǞ��[�Ặ�e�e��Hqo{�59i˲����O+��e������4�u�r��z�q~8c
 �G���7vr��tZ5�X�7����_qQc�[����uR��?/���+d��x�>r2����P6����`�k��,7�8�ɿ��O<Ė��}AM�E%�;�SI�BF���}��@P�yK�@��_:����R{��C_���9������
M��~����i����������s���������6�,�c�������q�����`����9���W�pXW]���:�n�aұt~9�[���~e�;��f���G���v0ԣ� ݈���y�,��:j%gox�T
�����kְ�����%<��A`���Jk?���� gm���x�*o4����o��.�����逊i�L����>���-���c�����5L����i�}�����4����usB������67��}����Z�ȶ�)+����)+H#ۢ�RK�AW�xww%��5�lfC�A���bP�lf��5����>���`0ċ/oA-�,�]ĝ�$�峋P2/���`���;����[Y��.&�Y�QlM���ƌb+��,�s�[��S ��}<;���]�:��y��1>'�AMm����7q���RY%9)���ȡI�]>�_l�C����-z�� ;>�-g�dt5іT�Aͺy�2w9���d�T��J�}u�}���X�Ks���<@��t��ebL������w�aw�N����c����F���3
�2먭�e���PQ�s�`��m<1u8�3�#����XMڈe�3�yb�p�m��܇+��x�%O?CmM-Yf��(�K�h�بU1%?I�X�r��� ��n^y�U�����1�玒�6..e��RJrRz�Oc������ʫ��]9���ZV�\�$IL�OŨ��{��M�p�L56��Wy��J�R{���FDA@
��^�y�������l6���{�=��ή�V�hM�V���JK��:��\�+��@�l/���ʧ����pQ��������׷Q^^�(�T������|.���9�?I�M���>���5�f欙X�VƎ-f͚ո���9����=�m���Y���c��Z�̚5��k~���gHHR�Ls/l9²���+ ����:��杧��"9�@��ad�ŝ��ѽ�Y���]O�W_�`Ֆ#Դ8�z��5-N^�r�Z����h���ʆY���=�`�M���Ty�l���.	�/z��fH���������֗�H�9�f������G� ̛<��q��|�]>ں}�N�3�;i�r"�(2RtY���4X���F�
�����8 �[�\锰�b`�0s�:���v���2�f��k�Zp��Ω&G���=��6em.mN�o.u�fԐc��i����C���u=~{�����a^�UH������¡,�t(jy�Q�ɋ����5�Gaw��/�Kv?�|K��(��SF�h�����V��xȩ2St쯹���{6b�M/�t��@0�{�Ԫ�"�v7�Q�A�(�ľR�<	�w�H1D�|8�]�]�Ո%����jҢ꯸hs�"~꯸P�B�� �%I}}��+f�����O�cg�3rd���P�������qIڻ]�h�c9��xh )z5��� �ƾ"1:3���j���'1;��#U�失g���0I}�u3.)@�Q�A�ĠQ`I�`�(1h��t*�:�>'��&v��!I?�/.)@�S�%q�\���l�TWq�������լ�G�5zy6w��[��5�r���L`�^���/x}�>��t4���cݦ�(�H�g��C�EA�g�)�Hfݦ��5�;q-���?ư�4�����K����XQ*�av�F��������񵏷�;>��l�\F��Þs�c�hL�5�G�c�������=q�P����E �.���'��8Us�{Ǎ���#������q�HDA`b��%����F�hog���|�������]K�n��UJ�}������Dk��g��8q���&G����A�RP�e�$'�i��I3j�w8������?�G�&<	&䪬R��lb1�J����B$�9�꤮�ES���[�������8�]��I�B!
�T
L:5�����d���K30"-	�(��D5�v��#U�����jԔ�QR�GIaó�I3�nJVk���&'��q����ux��AP<�"�Q�����H�`Jң�jP(D��]�����`0��+�p�inm�r�)��,^�_�rI�,��H>?M-44���x���"� �H�T��zIty����^B�.��%9?E����П�($@H!�D��#m�e���vB(��t �2.��8!���s2Tʡ �N;>w'����dq�"�2����O�9$�P	<(��z�Ff�<�z�N��/yD�t�/?�B.��A��>��i%�ǋ"�p n� ���]~!�W�J���a�q!n��V X*�c �TJT*%�6�<d[�    IEND�B`�        [remap]

importer="texture"
type="StreamTexture"
path="res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://icon.png"
dest_files=[ "res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=true
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
�PNG

   IHDR   @   @   �iq�  0IDATx��}pTU����L����W�$�@HA�%"fa��Yw�)��A��Egةf���X�g˱��tQ���Eq�!�|K�@BHH:�t>�;�����1!ݝn�A�_UWw����{λ��sϽO�q汤��X,�q�z�<�q{cG.;��]�_�`9s��|o���:��1�E�V� ~=�	��ݮ����g[N�u�5$M��NI��-
�"(U*��@��"oqdYF�y�x�N�e�2���s����KҦ`L��Z)=,�Z}"
�A�n{�A@%$��R���F@�$m������[��H���"�VoD��v����Kw�d��v	�D�$>	�J��;�<�()P�� �F��
�< �R����&�կ��� ����������%�u̚VLNfڠus2�̚VL�~�>���mOMJ���J'R��������X����׬X�Ϲ虾��6Pq������j���S?�1@gL���±����(�2A�l��h��õm��Nb�l_�U���+����_����p�)9&&e)�0 �2{��������1���@LG�A��+���d�W|x�2-����Fk7�2x��y,_�_��}z��rzy��%n�-]l����L��;
�s���:��1�sL0�ڳ���X����m_]���BJ��im�  �d��I��Pq���N'�����lYz7�����}1�sL��v�UIX���<��Ó3���}���nvk)[����+bj�[���k�������cݮ��4t:= $h�4w:qz|A��٧�XSt�zn{�&��õmQ���+�^�j�*��S��e���o�V,	��q=Y�)hԪ��F5~����h�4 *�T�o��R���z�o)��W�]�Sm銺#�Qm�]�c�����v��JO��?D��B v|z�կ��܈�'�z6?[� ���p�X<-���o%�32����Ρz�>��5�BYX2���ʦ�b��>ǣ������SI,�6���|���iXYQ���U�҅e�9ma��:d`�iO����{��|��~����!+��Ϧ�u�n��7���t>�l捊Z�7�nвta�Z���Ae:��F���g�.~����_y^���K�5��.2�Zt*�{ܔ���G��6�Y����|%�M	���NPV.]��P���3�8g���COTy�� ����AP({�>�"/��g�0��<^��K���V����ϫ�zG�3K��k���t����)�������6���a�5��62Mq����oeJ�R�4�q�%|�� ������z���ä�>���0�T,��ǩ�����"lݰ���<��fT����IrX>� � ��K��q�}4���ʋo�dJ��م�X�sؘ]hfJ�����Ŧ�A�Gm߽�g����YG��X0u$�Y�u*jZl|p������*�Jd~qcR�����λ�.�
�r�4���zپ;��AD�eЪU��R�:��I���@�.��&3}l
o�坃7��ZX��O�� 2v����3��O���j�t	�W�0�n5����#è����%?}����`9۶n���7"!�uf��A�l܈�>��[�2��r��b�O�������gg�E��PyX�Q2-7���ʕ������p��+���~f��;����T	�*�(+q@���f��ϫ����ѓ���a��U�\.��&��}�=dd'�p�l�e@y��
r�����zDA@����9�:��8�Y,�����=�l�֮��F|kM�R��GJK��*�V_k+��P�,N.�9��K~~~�HYY��O��k���Q�����|rss�����1��ILN��~�YDV��-s�lfB֬Y�#.�=�>���G\k֬fB�f3��?��k~���f�IR�lS'�m>²9y���+ �v��y��M;NlF���A���w���w�b���Л�j�d��#T��b���e��[l<��(Z�D�NMC���k|Zi�������Ɗl��@�1��v��Щ�!曣�n��S������<@̠7�w�4X�D<A`�ԑ�ML����jw���c��8��ES��X��������ƤS�~�׾�%n�@��( Zm\�raҩ���x��_���n�n���2&d(�6�,8^o�TcG���3���emv7m6g.w��W�e
�h���|��Wy��~���̽�!c� �ݟO�)|�6#?�%�,O֫9y������w��{r�2e��7Dl �ׇB�2�@���ĬD4J)�&�$
�HԲ��
/�߹�m��<JF'!�>���S��PJ"V5!�A�(��F>SD�ۻ�$�B/>lΞ�.Ϭ�?p�l6h�D��+v�l�+v$Q�B0ūz����aԩh�|9�p����cƄ,��=Z�����������Dc��,P��� $ƩЩ�]��o+�F$p�|uM���8R��L�0�@e'���M�]^��jt*:��)^�N�@�V`�*�js�up��X�n���tt{�t:�����\�]>�n/W�\|q.x��0���D-���T��7G5jzi���[��4�r���Ij������p�=a�G�5���ͺ��S���/��#�B�EA�s�)HO`���U�/QM���cdz
�,�!�(���g�m+<R��?�-`�4^}�#>�<��mp��Op{�,[<��iz^�s�cü-�;���쾱d����xk瞨eH)��x@���h�ɪZNU_��cxx�hƤ�cwzi�p]��Q��cbɽcx��t�����M|�����x�=S�N���
Ͽ�Ee3HL�����gg,���NecG�S_ѠQJf(�Jd�4R�j��6�|�6��s<Q��N0&Ge
��Ʌ��,ᮢ$I�痹�j���Nc���'�N�n�=>|~�G��2�)�D�R U���&ՠ!#1���S�D��Ǘ'��ೃT��E�7��F��(?�����s��F��pC�Z�:�m�p�l-'�j9QU��:��a3@0�*%�#�)&�q�i�H��1�'��vv���q8]t�4����j��t-}IـxY�����C}c��-�"?Z�o�8�4Ⱦ���J]/�v�g���Cȷ2]�.�Ǣ ��Ս�{0
�>/^W7�_�����mV铲�
i���FR��$>��}^��dُ�۵�����%��*C�'�x�d9��v�ߏ � ���ۣ�Wg=N�n�~������/�}�_��M��[���uR�N���(E�	� ������z��~���.m9w����c����
�?���{�    IEND�B`�       ECFG      _global_script_classes             _global_script_class_icons             application/config/name         Project Blam   application/run/main_scene         res://World.tscn   application/config/icon         res://icon.png     input/ui_accept0              deadzone      ?      events              InputEventJoypadButton        resource_local_to_scene           resource_name             device            button_index          pressure          pressed           script               InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode        unicode           echo          script            input/ui_cancel0              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode        unicode           echo          script               InputEventJoypadButton        resource_local_to_scene           resource_name             device            button_index         pressure          pressed           script            input/ui_left              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode   A      unicode           echo          script               InputEventJoypadMotion        resource_local_to_scene           resource_name             device            axis       
   axis_value       ��   script            input/ui_right              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode   D      unicode           echo          script               InputEventJoypadMotion        resource_local_to_scene           resource_name             device            axis       
   axis_value       �?   script            input/ui_up              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode   W      unicode           echo          script               InputEventJoypadMotion        resource_local_to_scene           resource_name             device            axis      
   axis_value       ��   script            input/ui_down              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode   S      unicode           echo          script               InputEventJoypadMotion        resource_local_to_scene           resource_name             device            axis      
   axis_value       �?   script            input/ui_endd              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode        unicode           echo          script            input/game_shoot|              deadzone      ?      events              InputEventMouseButton         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           button_mask           position              global_position               factor       �?   button_index         pressed           doubleclick           script               InputEventJoypadMotion        resource_local_to_scene           resource_name             device            axis      
   axis_value       �?   script            input/game_grenade�              deadzone      ?      events              InputEventMouseButton         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           button_mask           position              global_position               factor       �?   button_index         pressed           doubleclick           script            input/game_look_up�               deadzone      ?      events              InputEventJoypadMotion        resource_local_to_scene           resource_name             device            axis      
   axis_value       ��   script            input/game_look_down�               deadzone      ?      events              InputEventJoypadMotion        resource_local_to_scene           resource_name             device            axis      
   axis_value       �?   script            input/game_look_left�               deadzone      ?      events              InputEventJoypadMotion        resource_local_to_scene           resource_name             device            axis      
   axis_value       ��   script            input/game_look_right�               deadzone      ?      events              InputEventJoypadMotion        resource_local_to_scene           resource_name             device            axis      
   axis_value       �?   script            physics/3d/physics_engine         Bullet  )   rendering/environment/default_environment          res://default_env.tres      GDPC