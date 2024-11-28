extends CharacterBody3D


var ACC = 70
var FRICTION = 40
var max_speed = 5

const SPEED = 5.0
const JUMP_VELOCITY = 10
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var enabled = true

# debug

@export var debug_teleport_point: Node3D


func _ready():
	if not enabled:
		self.queue_free()


func _physics_process(_delta):
	_physics_movement(self, _delta)
	
	# shoot weapon (player clue)
	
	if Input.is_action_just_pressed("p1_shoot"):
		var cue = IAModel.create_cue(IAModel.CUE_TYPE.ENEMY, get_feet_position(), $EntityDetectable)
		IAHearingManager.get_singleton().report_sound(cue)
	
	if Input.is_action_just_pressed("debug_action1"):
		global_position = debug_teleport_point.global_position
	

func _physics_movement(body: CharacterBody3D, _delta):
	
	var horizontal_vel = Vector2(body.velocity.x, body.velocity.z)
	
	# random force
	
	#if Input.is_action_just_pressed("ui_accept"):
	#	body.velocity += Vector3(40,0,0)
	
	# gravity
	
	if not is_on_floor():
		body.velocity.y -= gravity * _delta
	elif Input.is_action_just_pressed("p1_jump"):
		print("jump")
		body.velocity.y += JUMP_VELOCITY
	
	# apply friction

	var friction: float = FRICTION * _delta
	if horizontal_vel.length() < friction:
		horizontal_vel = Vector2.ZERO
	else:
		horizontal_vel -= horizontal_vel.normalized() * friction

	# apply input

	var movement_dir_2d = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	var movement_dir = Vector2(movement_dir_2d.x, movement_dir_2d.y)
	var increment = movement_dir * ACC * _delta
	var max_speed = max_speed
	var curr_speed = horizontal_vel.length()
	var would_be_speed = (horizontal_vel + increment).length()

	# Two cases:
	# (1) reduce speed

	if would_be_speed < curr_speed:
		horizontal_vel += increment

	# (2) increase speed
	else:

		# allow to achieve maximum speed
		if curr_speed < max_speed && would_be_speed > max_speed:
			curr_speed = max_speed

		# allow to move from stall
		elif would_be_speed <= max_speed:
			curr_speed += increment.length()

		# merge directions
		var dir = (horizontal_vel + increment).normalized()
		horizontal_vel = dir * curr_speed

	# integrate
	body.velocity.x = horizontal_vel.x
	body.velocity.z = horizontal_vel.y
	body.move_and_slide()

"""
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()"""


func get_eyes_position() -> Vector3:
	return $EyesPosition.global_position

func get_feet_position() -> Vector3:
	return global_position
