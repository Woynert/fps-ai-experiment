extends CharacterBody3D

@export var enabled = true

func _ready():
	if not enabled:
		self.queue_free()

func _physics_process(delta):
	
	# shoot weapon (player clue)
	
	if Input.is_action_just_pressed("p1_shoot"):
		var cue = IAModel.create_cue(IAModel.CUE_TYPE.ENEMY, global_position, $EntityDetectable)
		IAHearingManager.get_singleton().report_sound(cue)

func get_eyes_position() -> Vector3:
	return $EyesPosition.global_position

func get_feet_position() -> Vector3:
	return global_position
