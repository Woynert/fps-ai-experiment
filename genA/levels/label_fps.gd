extends Label


func _physics_process(delta: float) -> void:
	text = """real_fps %s
	physic_fps %s
	""" % [
		Engine.get_frames_per_second(),
		Engine.physics_ticks_per_second,
	]
