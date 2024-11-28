extends IASense
class_name IASenseVision

@export var DIST_RANGE: float = 20.0
@export var ANGLE_RANGE: float = 70.0

var COS_ANGLE_RANGE: float = cos(deg_to_rad(ANGLE_RANGE))
var self_entity: Node3D = null

@onready var ray: RayCast3D = $Ray


func setup(self_entity: Node3D):
	self.self_entity = self_entity


func sense(aim: Vector3) -> Array[IAModel.Cue]:
	var cues: Array[IAModel.Cue] = []
	var entities = EntityManager.get_singleton().entities
	var self_eyes = self_entity.get_eyes_position()
	for i in range(entities.size()):
		var entity: EntityDetectable = entities[i]
		var target_entity: Node3D = entity.get_root_node()
		var target_eyes: Vector3 = target_entity.get_eyes_position()

		# TODO: is not an ally
		
		# not myself WARNING: This doesn't work yet 
		if entity == self_entity:
			continue
			
		# too far
		if self_entity.global_position.distance_squared_to(target_entity.global_position) > (DIST_RANGE * DIST_RANGE):
			continue
		
		# in vision cone
		#var dir_forward = aim #* Vector3.MODEL_FRONT
		var dir_forward = Quaternion.from_euler(aim) * Vector3.MODEL_FRONT
		var dir_to_entity = self_eyes.direction_to(target_eyes)
		if dir_forward.dot(dir_to_entity) < COS_ANGLE_RANGE:
			continue
			
		# direct view
		ray.global_position = self_eyes
		ray.target_position = target_eyes - self_eyes
		ray.force_raycast_update()
		if ray.is_colliding():
			continue
			
		var cue = IAModel.create_cue(IAModel.CUE_TYPE.ENEMY, target_entity.get_feet_position(), entity)
		cues.append(cue)
	
	return cues


func can_see_entity(target_entity: Node3D, aim: Vector3) -> bool:
	if self_entity.global_position.distance_squared_to(target_entity.global_position) > (DIST_RANGE * DIST_RANGE):
		return false
		
	# in vision cone
	var self_eyes = self_entity.get_eyes_position()
	var target_eyes: Vector3 = target_entity.get_eyes_position()
	var dir_forward = Quaternion.from_euler(aim) * Vector3.MODEL_FRONT
	var dir_to_entity = self_eyes.direction_to(target_eyes)
	if dir_forward.dot(dir_to_entity) < COS_ANGLE_RANGE:
		return false
		
	# direct view
	ray.global_position = self_eyes
	ray.target_position = target_eyes - self_eyes
	ray.force_raycast_update()
	if ray.is_colliding():
		return false
		
	return true
