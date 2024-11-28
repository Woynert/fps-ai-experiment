extends Node3D
class_name IASpotterManager


@onready var ray: RayCast3D = $Ray
@onready var ray_debug: RayCast3D = $RayDebug

const THINK_TICK_DELAY: int = 2
var tick: int = 0


const MAX_FLOOR_DEPTH: float = 3.0
const EYE_HEIGHT: float = 2.0
const AGENT_RADIUS: float = 0.5

const RAYS: int = 10
const RAY_LENGTH: float = 16.0
const DIVISIONS: int = 5

var current_ray: int = 0
var current_division: int = 0
var last_height: float = EYE_HEIGHT


var points: Array[Array] = []
class Point:
	var ready: bool
	var node: Node3D
	var position: Vector3


func _ready():
	last_height = global_position.y + EYE_HEIGHT
	
	# initialize array
	points.resize(RAYS)
	for i in range(RAYS):
		var divisions: Array[Point] = []
		divisions.resize(DIVISIONS)
		points[i] = divisions
		
		for j in range(DIVISIONS):
			var point = Point.new()
			point.ready = false
			divisions[j] = point


func _physics_process(delta):
	if tick % THINK_TICK_DELAY == 0:
		_think()
	tick += 1


func _think():
	
	# create one at a frame
	var origin: Vector3 = Vector3(global_position.x, last_height, global_position.z)
	var direction: Vector3 = Vector3.RIGHT.rotated(Vector3.UP, (2 * PI) / RAYS * current_ray)
	var division_length = RAY_LENGTH / DIVISIONS
	
	# check horizontal space
	ray.global_position = origin + direction * division_length * current_division
	ray.target_position = direction * (division_length * 0.5 + AGENT_RADIUS)
	ray.force_raycast_update()
	if ray.is_colliding():
		_advance_ray()
		return
		
	#ray_debug.global_position = ray.global_position
	#ray_debug.target_position = ray.target_position
	
	# check floor
	
	ray.global_position = origin + direction * division_length * (current_division + 0.5)
	ray.target_position = Vector3.DOWN * MAX_FLOOR_DEPTH
	ray.force_raycast_update()
	if !ray.is_colliding():
		_advance_ray()
		return
		
	last_height = ray.get_collision_point().y + EYE_HEIGHT
	_register_point(current_ray, current_division, ray.get_collision_point())
	
	# loop
	current_division += 1
	if current_division == DIVISIONS:
		_advance_ray()


func _advance_ray():
	# set points as not ready
	for i in range(current_division, DIVISIONS):
		var point = points[current_ray][i]
		point.ready = false
		if point.node:
			point.node.visible = false
	
	current_ray += 1
	current_division = 0
	last_height = global_position.y + EYE_HEIGHT
	
	if current_ray >= RAYS:
		current_ray = 0


func _register_point(ray: int, division: int, pos: Vector3):
	var point = points[ray][division]
	point.ready = true
	point.position = pos
	var instance = point.node
	if !instance:
		instance = MeshInstance3D.new()
		instance.mesh = SphereMesh.new()
		get_tree().root.add_child(instance)
		point.node = instance
	instance.global_position = pos
	instance.visible = true


func get_points_plain() -> Array[Vector3]:
	var array: Array[Vector3] = []
	for ray in points:
		for point in ray:
			if point.ready:
				array.append(point.position)
	return array


func get_points_nested_array_dirty() -> Array[Array]:
	return points
