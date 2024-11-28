extends CharacterBody3D
class_name IAPhysicManager

signal signal_target_reached

var ACC = 70
var FRICTION = 40
var max_speed = 5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


const MAX_H_SPEED = 5.0
const MAX_H_SPEED_SQRD = MAX_H_SPEED ** 2
const GRAVITY = 0.15

const PROXIMITY_TO_LOCATION_SQRD = 1 ** 2

const MIN_ATTACK_RANGE_SQRD = 3.0 ** 2
const MAX_ATTACK_RANGE_SQRD = 6.0 ** 2

var enabled_to_move = false
var move_inputs_enabled = false
var local_target_location: Vector3
var next_step_location: Vector3

@onready var navigation: NavigationAgent3D = $NavigationAgent3D
@onready var common: IACommon = $".."
@onready var spotter: IASpotterManager = $IASpotterManager
@onready var debug_target_position: Node3D = $"../target_position"


func _physics_process(delta):
	
	var state = common.state_manager
	var input = Vector2.ZERO
	var aim_towards: Vector3
	
	if enabled_to_move:
		
		# think about where to go
		
		match state.current_action:
			IAModel.FOCUS_ACTION.IDLE:
				pass
			
			IAModel.FOCUS_ACTION.RETREATING, \
			IAModel.FOCUS_ACTION.SEARCHING, \
			IAModel.FOCUS_ACTION.INSPECTING:
				
				next_step_location = navigation.get_next_path_position()
				debug_target_position.global_position = next_step_location

				# reached target
				if _is_near_location(local_target_location, PROXIMITY_TO_LOCATION_SQRD):
					move_inputs_enabled = false
					signal_target_reached.emit()
				else:
					move_inputs_enabled = true
			
			IAModel.FOCUS_ACTION.CHASING:
				next_step_location = navigation.get_next_path_position()
				debug_target_position.global_position = next_step_location
				
				var dist = global_position.distance_squared_to(state.target_location)
				
				if ((dist > MIN_ATTACK_RANGE_SQRD && dist < MAX_ATTACK_RANGE_SQRD)):
					move_inputs_enabled = false
					#print("I: in range")
				# TODO: instead use a timer which updates the position periodically
				else:
					#print("I: NOT in range")
					var dist_from_local_target = local_target_location.distance_squared_to(state.target_location)
					
					if !move_inputs_enabled || !(dist_from_local_target > MIN_ATTACK_RANGE_SQRD && dist_from_local_target < MAX_ATTACK_RANGE_SQRD):
						var point_in_range = select_point_in_range(state.target_location)
						if point_in_range:
							navigation_set_target(point_in_range)
							move_inputs_enabled = true
								
		# move to
			
		if move_inputs_enabled:
			input = Vector2(global_position.x, global_position.z).direction_to(Vector2(next_step_location.x, next_step_location.z)).normalized()
			#print("input moving %s" % input)
		
	_physics_movement(self, input, delta)
	
	# aim
	
	match state.current_action:
		IAModel.FOCUS_ACTION.IDLE:
			pass
		
		IAModel.FOCUS_ACTION.RETREATING, \
		IAModel.FOCUS_ACTION.SEARCHING:
					
			# look at path
			aim_towards = global_position.direction_to(next_step_location)
			_rotate_aim_towards_vector_dir(aim_towards)

		IAModel.FOCUS_ACTION.INSPECTING:
			# look around
			var ticks = Engine.get_physics_frames()
			var inspect_look_angle = deg_to_rad(180 / 2)
			
			var aim_vector = Vector3(0, common.state_manager.aim.y, 0)
			aim_vector.y += sin(ticks / 50.0) * 0.3 # TODO: Magical numbers!
			_rotate_aim_towards_euler(aim_vector)
			
		IAModel.FOCUS_ACTION.CHASING:
			# look at enemy
			aim_towards = global_position.direction_to(common.state_manager.locked_enemy_location)
			_rotate_aim_towards_vector_dir(aim_towards)


func _rotate_aim_towards_vector_dir(aim_towards: Vector3):
	# avoid aim to look exactly up or exactly down

	aim_towards = aim_towards.normalized()
	
	var xz_vector = Vector2(aim_towards.z, aim_towards.x)
	var yaw = Vector2(1,0).angle_to(xz_vector)
	var pitch = Vector2(1,0).angle_to(Vector2(xz_vector.length(), -aim_towards.y))
	var target_euler = Vector3(pitch, yaw, 0)
	
	#print("target_euler %s %s %s" % [target_euler, rad_to_deg(a), rad_to_deg(b)])
	_rotate_aim_towards_euler(target_euler)


func _rotate_aim_towards_euler(target_euler: Vector3):
	target_euler.z = 0
	common.state_manager.aim.x = lerp_angle(common.state_manager.aim.x, target_euler.x, 0.1)
	common.state_manager.aim.y = lerp_angle(common.state_manager.aim.y, target_euler.y, 0.1)
	($visualRotation1 as Node3D).global_rotation = common.state_manager.aim


# movement

func _physics_movement(body: CharacterBody3D, movement_dir_2d: Vector2, _delta):
	
	var horizontal_vel = Vector2(body.velocity.x, body.velocity.z)
	
	# gravity
	
	if not is_on_floor():
		body.velocity.y -= gravity * _delta
	
	# apply friction

	var friction: float = FRICTION * _delta
	if horizontal_vel.length() < friction:
		horizontal_vel = Vector2.ZERO
	else:
		horizontal_vel -= horizontal_vel.normalized() * friction

	# apply input

	var movement_dir = Vector2(movement_dir_2d.x, movement_dir_2d.y).normalized()
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


# public

func stop():
	move_inputs_enabled = false
	navigation.target_position = global_position


# TODO: functions that allows for tailoring the kind of places to select from. i. e. hide, search, defense position

func navigation_set_target(target: Vector3):
	move_inputs_enabled = true
	navigation.target_position = target
	local_target_location = navigation.get_final_position()
	#debug_target_position.global_position = target
	print("navigation_set_target")

func is_near_location(target: Vector3) -> bool:
	return global_position.distance_squared_to(target) < PROXIMITY_TO_LOCATION_SQRD


func _is_near_location(target: Vector3, dist: float) -> bool:
	#print("distance1 ", global_position.distance_to(target))
	#print("distance2 ", global_position.distance_squared_to(target))
	return global_position.distance_squared_to(target) < dist


static func get_up_basis_from_vector3(vector_p: Vector3) -> Basis:
	var forward = vector_p.normalized()
	var right = Vector3(forward.z, 0, -forward.x).normalized()
	if right == Vector3.ZERO: right = Vector3.RIGHT
	var up = forward.cross(right).normalized()
	return Basis(right, up, -forward)


func direction_to_quaternion(to: Vector3) -> Quaternion:
	"""
	Handle special case if the vector is the opposite
	"""
	to = to.normalized()
	if to == Vector3.BACK:
		return Quaternion(Vector3.UP, PI)
	return Quaternion(Vector3.FORWARD.cross(to).normalized(), Vector3.FORWARD.angle_to(to))


func select_point_in_range(target: Vector3) -> Vector3:
	var points: Array[Array] = spotter.get_points_nested_array_dirty()
	var rays = points.size()
	var divisions = points[0].size()
	
	var distance: float
	var point: IASpotterManager.Point
	for j in range(divisions):
		for i in range(rays):
			point = points[i][j]
			if !point.ready:
				continue
			distance = target.distance_squared_to(point.position)
			print("%s %s %s" % [i, j, sqrt(distance)])
			if distance > MIN_ATTACK_RANGE_SQRD && distance < MAX_ATTACK_RANGE_SQRD:
				return point.position
	
	return Vector3.ZERO


func get_eyes_position() -> Vector3:
	return $EyesPosition.global_position
	
