extends Node3D
class_name IAStateManager

const MAX_CUES: int = 5
const BUSY_TIMEOUT: int = 10
const CHASE_TIMEOUT: int = 1

var entity_id: int
var peloton_id: int
var aim: Vector3 # EULER_ORDER_YXZ: (x) Y (yaw), (y) X (pitch), (z) Z (roll UNUSED), 
var cues: Array[IAModel.Cue] = []

var alert_state: IAModel.ALERT_STATE = IAModel.ALERT_STATE.DEFENDING
var current_action: IAModel.FOCUS_ACTION = IAModel.FOCUS_ACTION.IDLE

var searching: bool = false
var busy: bool = false
var busy_since: int = 0

var target_location: Vector3
var locked_enemy_location: Vector3
var locked_enemy_id: int

@onready var position_to_return_to: Vector3 = self.global_position
@onready var common: IACommon = $".."


func setup(entity_id: int, peloton_id: int):
	self.entity_id = entity_id
	self.peloton_id = peloton_id
	common.senses_manager.signal_cue.connect(register_cue)


func register_cue(cue: IAModel.Cue):
	# Do not communicate the origin 'ENEMY' since it's reserved for the owner only
	if cue.type == IAModel.CUE_TYPE.ENEMY:
		var cue_enemy_reported = IAModel.create_cue(IAModel.CUE_TYPE.ENEMY_REPORTED, cue.position)
		PelotonManager.get_singleton().get_peloton(peloton_id).communicate_cue(entity_id, cue_enemy_reported)
	
	# don't remove this cue / don't add more cues when you have this
	# Maybe let add a cue if it's more important
	# TODO: Make a priority system for cues
	var has_enemy_cue = common.logic_manager.is_cue_type(cues, IAModel.CUE_TYPE.ENEMY)
	if has_enemy_cue:
		return
	
	cues.append(cue)
	if cues.size() > MAX_CUES:
		cues.pop_front()
		
	# force logic update, maybe this isn't necesary, but what about the flicker?
	#common.logic_manager.think()


func remove_cue(cue: IAModel.Cue):
	cues.erase(cue)
