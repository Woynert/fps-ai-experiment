extends CharacterBody3D

@export var path_target: NodePath
@onready var target_position: Vector3 = get_node(path_target).global_position
@onready var navigation: NavigationAgent3D = $NavigationAgent3D

const SPEED = 600.0
const GRAVITY = 9.1

func _ready():
	navigation.target_position = target_position

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	var next_position: Vector3 = navigation.get_next_path_position()
	var direction = global_position.direction_to(next_position)
	var velocity_h = Vector2(direction.x, direction.z).normalized() * SPEED * delta
	velocity = Vector3(velocity_h.x, velocity.y, velocity_h.y)

	move_and_slide()
