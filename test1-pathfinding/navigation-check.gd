extends NavigationRegion3D

@export var delete: bool = false

func _ready():
	_check()
	if delete:
		queue_free()
	pass
	
func _check():
	print("Alright %s" % name)
	print(navigation_mesh.get_vertices())
	print(navigation_mesh.get_polygon_count())
	print(navigation_mesh.get_collision_mask_value(1))
