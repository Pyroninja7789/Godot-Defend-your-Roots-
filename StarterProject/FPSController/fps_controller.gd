extends CharacterBody3D

@export var look_sensitivity : float = 0.006
@export var jump_velocity := 6.0
@export var auto_bhop := true
@export var walk_speed := 7.0
@export var sprint_speed := 8.5

const HEADBOB_MOVE_AMOUNT = 0.06
const HEADBOB_FREQUENCY = 2.4
var headbob_time := 0.0

var wish_dir := Vector3.ZERO

func get_move_speed() -> float:
	return sprint_speed if Input.is_action_pressed("sprint") else walk_speed

func _fireing():
		if %RayCast3D.is_colliding():
			var collider = %RayCast3D.get_collider() # Object hit by the ray
			var collision_point = %RayCast3D.get_collision_point() # Collision location
			var collision_normal = %RayCast3D.get_collision_normal() # Surface normal
			print("Collided with:", collider.name)

func _ready():
	for child in %WorldModel.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sensitivity)
			%Sketchfab_Scene.rotate_x(-event.relative.y * look_sensitivity)
			%Sketchfab_Scene.rotation.z = clamp(%Sketchfab_Scene.rotation.z, deg_to_rad(-90), deg_to_rad(90))
			%Camera3D.rotate_x(-event.relative.y * look_sensitivity)
			%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))
			%RayCast3D.rotate_x(-event.relative.y * look_sensitivity)
			%RayCast3D.rotation.x = clamp(%RayCast3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))
			
			
func _headbob_effect(delta):
	headbob_time += delta * self.velocity.length()
	%Camera3D.transform.origin = Vector3(
		cos(headbob_time * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUNT,
		sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUNT,
		0,
	)

func _process(delta):
	pass

func _handle_air_physics(delta) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

func _handle_ground_physics(delta) -> void:
	self.velocity.x = wish_dir.x * get_move_speed()
	self.velocity.z = wish_dir.z * get_move_speed()
	
	_headbob_effect(delta)

func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "up", "down")
	# Depending on which way you have your character facing, you may need to negate the input directions
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	
	if Input.is_action_just_pressed("Shoot"):
		_fireing()
		
	if Input.is_action_just_pressed("stab"):
		%AnimationPlayer.play("swing")
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			self.velocity.y = jump_velocity
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
		
	move_and_slide()
