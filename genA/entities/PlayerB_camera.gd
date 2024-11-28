extends Camera3D
class_name DebugOracle

@export var enabled = true
@onready var camera = self as Camera3D
var prev_camera: Camera3D = null

var mouseSensibility = 800
var velocity = Vector3.ZERO

const SPEED = 5.0
const FLY_VELOCITY = 4.5
#const GRAVITY = 10
const JUMP_VELOCITY = 5
var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

func update():
	if enabled:
		prev_camera = get_viewport().get_camera_3d()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera.make_current()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if prev_camera:
			prev_camera.make_current()

func _physics_process(delta):
	# inputs
	if Input.is_action_just_pressed("ui_text_delete"):
		enabled = !enabled
		update()
	if !enabled: return
	var input_dir = Vector3(
		int(Input.is_key_pressed(KEY_A)) - int(Input.is_key_pressed(KEY_D)),
		int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W)),
		int(Input.is_key_pressed(KEY_SPACE)) - int(Input.is_key_pressed(KEY_SHIFT))
	)
	#input_dir.z = 0 # WARNING: delete me to restore flight
	var raw_dir = camera.transform.basis * Vector3.FORWARD
	var direction = (Vector3(raw_dir.x, 0, raw_dir.z)).normalized()
	direction = get_up_basis_from_vector3(direction) * Vector3(input_dir.x, 0, input_dir.y)
	
	
	velocity = get_parent().velocity
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	
	if not get_parent().is_on_floor():
		velocity.y -= GRAVITY * delta
	elif input_dir.z > 0:
		print("jump")
		velocity.y += JUMP_VELOCITY
	
	#velocity.y = input_dir.z * FLY_VELOCITY
	#global_position += velocity * delta
	get_parent().velocity = velocity #* delta
	get_parent().move_and_slide()

func _input(event):
	if !enabled: return
	if event is InputEventMouseMotion:
		camera.rotation.y -= event.relative.x / mouseSensibility
		camera.rotation.x -= event.relative.y / mouseSensibility
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89) )

func get_up_basis_from_vector3(vector_p: Vector3) -> Basis:
	var forward = vector_p.normalized()
	var right = Vector3(forward.z, 0, -forward.x).normalized()
	if right == Vector3.ZERO: right = Vector3.RIGHT
	var up = forward.cross(right).normalized()
	return Basis(right, up, -forward)
