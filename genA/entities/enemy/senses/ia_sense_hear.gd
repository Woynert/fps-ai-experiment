extends IASense
class_name IASenseHear

@export var DIST_RANGE: float = 10.0
var self_entity: Node3D = null

signal signal_cue(cue: IAModel.Cue)


func setup(self_entity: Node3D):
	self.self_entity = self_entity
	IAHearingManager.get_singleton().signal_sound.connect(_process_sound)


func _process_sound(cue: IAModel.Cue):
	if self_entity.global_position.distance_squared_to(cue.position) > (DIST_RANGE * DIST_RANGE):
		return
	signal_cue.emit(cue)
