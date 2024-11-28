extends Node
class_name EntityDetectable

var id: int

func _ready():
	id = EntityManager.get_singleton().register(self)
	
func get_root_node():
	return get_parent()
