extends Node
class_name IALogicManager

const THINK_TICK_DELAY: int = 20
var tick: int = 0
@onready var common: IACommon = $".."
@onready var physic_manager: IAPhysicManager = $"../IAPhysicManager"
@onready var state: IAStateManager = $"../IAStateManager"
@onready var debug_enemy_position: Node3D = $"../enemy_position"

func setup():
	print("D: testing physics manager pathfinding")
	common.physic_manager.signal_target_reached.connect(on_target_reached)


func _physics_process(delta):
	if tick % THINK_TICK_DELAY == 0:
		think()
	tick += 1


func think():
	print(get_parent().name, "think")
	# any
	var cue = is_cue_type(state.cues, IAModel.CUE_TYPE.ENEMY)
	if cue:
		print("D: ENEMY go attack")
		
		var entity: EntityDetectable = cue.entity
		if entity:
			if state.alert_state != IAModel.ALERT_STATE.ATTACKING:
				state.locked_enemy_id = entity.id
				state.locked_enemy_location = cue.position
				_set_target_location(cue.position)
				debug_enemy_position.global_position = cue.position
			elif state.locked_enemy_id == entity.id:
				state.locked_enemy_location = cue.position
				_set_target_location(cue.position, false)
				debug_enemy_position.global_position = cue.position
			
		if state.current_action in IAModel.MOVABLE_FOCUS_ACTIONS:
			state.current_action = IAModel.FOCUS_ACTION.CHASING
			_set_target_location(cue.position)
			debug_enemy_position.global_position = cue.position
		
		state.remove_cue(cue)
		state.busy_since = Time.get_unix_time_from_system()
		state.alert_state = IAModel.ALERT_STATE.ATTACKING
	
	# defending
	if state.alert_state == IAModel.ALERT_STATE.DEFENDING:
		
		cue = is_cue_type(state.cues, IAModel.CUE_TYPE.ENEMY_REPORTED)
		if cue:
			state.remove_cue(cue)
			
			state.current_action = IAModel.FOCUS_ACTION.SEARCHING
			state.busy_since = Time.get_unix_time_from_system()
			_set_target_location(cue.position)
			debug_enemy_position.global_position = cue.position
			print("D: ENEMY_REPORTED start searching")

		elif state.current_action == IAModel.FOCUS_ACTION.SEARCHING:
			# go to last position
			if common.physic_manager.is_near_location(state.target_location):
				state.current_action = IAModel.FOCUS_ACTION.INSPECTING
				state.busy_since = Time.get_unix_time_from_system()
				print("D: start inspecting")
				return
				
			# timeout, return to base
			if Time.get_unix_time_from_system() > (state.busy_since + state.BUSY_TIMEOUT):
				state.current_action = IAModel.FOCUS_ACTION.RETREATING
				state.busy_since = Time.get_unix_time_from_system()
				_set_target_location(state.position_to_return_to)
				print("D: return to base")
				return
		
		elif state.current_action == IAModel.FOCUS_ACTION.INSPECTING:
			if Time.get_unix_time_from_system() > (state.busy_since + state.BUSY_TIMEOUT):
				state.current_action = IAModel.FOCUS_ACTION.RETREATING
				state.busy_since = Time.get_unix_time_from_system()
				_set_target_location(state.position_to_return_to)
				print("D: return to base")
				return
		
		else:
			cue = is_cue_type(state.cues, IAModel.CUE_TYPE.SUSPICIUS)
			if cue:
				state.remove_cue(cue)
				
				# if it isn't taken then take it
				var peloton = PelotonManager.get_singleton().get_peloton(state.peloton_id)
				if peloton.is_cue_taken(cue.id):
					return
				peloton.take_cue(cue)
				
				# start search
				state.current_action = IAModel.FOCUS_ACTION.SEARCHING
				state.busy_since = Time.get_unix_time_from_system()
				_set_target_location(cue.position)
				debug_enemy_position.global_position = cue.position
				print("D: start searching")
		
	# attacking
	elif state.alert_state == IAModel.ALERT_STATE.ATTACKING:
		if state.current_action == IAModel.FOCUS_ACTION.CHASING:
			if Time.get_unix_time_from_system() > (state.busy_since + state.CHASE_TIMEOUT):
				state.current_action = IAModel.FOCUS_ACTION.SEARCHING
				state.busy_since = Time.get_unix_time_from_system()
				_set_target_location(state.locked_enemy_location)
				print("D: can't let him get away")
				
			# if target in sight
				# attack
			if common.attack_manager.ready_to_attack():
				var entity_manager = EntityManager.get_singleton()
				var enemy_stub = entity_manager.get_entity(state.locked_enemy_id)
				if enemy_stub != null:
					var enemy_node = enemy_stub.get_root_node()
					if enemy_node is Node3D && common.sense_vision.can_see_entity(enemy_node, state.aim):
						common.attack_manager.attack(state.aim)
				
		elif Time.get_unix_time_from_system() > (state.busy_since + state.BUSY_TIMEOUT):
			state.alert_state = IAModel.ALERT_STATE.DEFENDING
			state.current_action = IAModel.FOCUS_ACTION.SEARCHING
			state.busy_since = Time.get_unix_time_from_system()
			_set_target_location(state.position_to_return_to)
			print("D: enemy lost")
			return


func on_target_reached():
	var state = common.state_manager
	if state.current_action == IAModel.FOCUS_ACTION.RETREATING:
		state.current_action = IAModel.FOCUS_ACTION.IDLE
		physic_manager.enabled_to_move = false
	
	# While attacking: inspect to make sure to not lose it
	# While defending: inspect to get the full picture
	if state.current_action == IAModel.FOCUS_ACTION.SEARCHING:
		state.current_action = IAModel.FOCUS_ACTION.INSPECTING


func _set_target_location(target: Vector3, update_physics_navigation: bool = true):
	state.target_location = target
	physic_manager.enabled_to_move = true
	if update_physics_navigation:
		physic_manager.navigation_set_target(target)


static func is_cue_type(cues: Array[IAModel.Cue], type: IAModel.CUE_TYPE) -> IAModel.Cue:
	for cue in cues:
		if cue.type == type:
			return cue
	return null
