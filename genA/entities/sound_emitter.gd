extends Node3D
@export var delay: int = 0 # seconds


func _ready():
	var timer: Timer = $Timer as Timer
	timer.start(delay)
	timer.timeout.connect(emit)


func emit():
	print("D: Sound emitted")
	var cue = IAModel.create_cue(IAModel.CUE_TYPE.SUSPICIUS, global_position)
	IAHearingManager.get_singleton().report_sound(cue)
	queue_free()
