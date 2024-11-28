extends Node3D
class_name Peloton

const CUE_TIMEOUT = 20 # seconds
const THINK_TICK_DELAY = 60 / 1 # 1 times per second on 60 fps

var tick: int = 0
var peloton_id: int = -1
var points: Array[Vector3] = []
var entities: Array[IACommon] = []
var taken_cues: Array[IAModel.Cue] = []


func _ready():
	self.peloton_id = PelotonManager.get_singleton().register(self)
	setup_entities()


func setup_entities():
	for point in $points.get_children():
		points.append(point.global_position)
	for node in $entities.get_children():
		var entity = node as IACommon
		if !entity:
			continue
		entity.state_manager.setup(entities.size(), peloton_id)
		entities.append(entity)


func _physics_process(delta):
	# TODO: clean old taken cues periodically
	if tick % THINK_TICK_DELAY == 0:
		cleanup()
	tick += 1


func cleanup():
	for cue in taken_cues:
		if Time.get_unix_time_from_system() > (cue.timestamp + CUE_TIMEOUT):
			taken_cues.erase(cue)


func is_cue_taken(id: int) -> bool:
	for taken_cue in taken_cues:
		if taken_cue.id == id:
			return true
	return false


func take_cue(cue: IAModel.Cue):
	taken_cues.append(cue)


func communicate_cue(entity_id: int, cue: IAModel.Cue):
	for entity: IACommon in entities:
		if entity.state_manager.entity_id == entity_id:
			continue
		entity.state_manager.register_cue(cue)
