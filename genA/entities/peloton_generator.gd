extends MeshInstance3D

@export var enable: bool = true
@export var width: int = 3
@export var height: int = 3

const SCN_ENEMY = preload("res://genA/entities/enemy/enemy.tscn")
const GAP = 3

func _ready() -> void:
	# create peloton
	var peloton = $Peloton
	var entities_node = $Peloton/entities
	
	# create enemies
	for i in range(width):
		for j in range(height):
			var inst = SCN_ENEMY.instantiate()
			inst.position = Vector3(i * GAP, 0, j * GAP)
			entities_node.add_child(inst)
			
	
	peloton.setup_entities()
