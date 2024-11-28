extends ShapeCast3D
class_name DebugProjectile

const scn_projectile = preload("res://genA/entities/projectile/projectile.tscn")
const SPEED = 10

var dir_cart: Vector3 = Vector3.MODEL_FRONT


static func spawn(father: Node, pos: Vector3, dir_euler: Vector3):
	var inst = scn_projectile.instantiate()
	inst.global_position = pos
	father.add_child(inst)
	inst.dir_cart = Quaternion.from_euler(dir_euler) * Vector3.MODEL_FRONT
	return


func _ready() -> void:
	$Timer.timeout.connect(_destroy)
	print("DebugProjectile: Created")


func _destroy():
	print("DebugProjectile: Destroyed")
	self.queue_free()

func _physics_process(delta: float) -> void:
	global_position += dir_cart * SPEED * delta
	
	if is_colliding():
		_destroy()
