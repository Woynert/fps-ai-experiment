extends Node
class_name IAModel

enum ALERT_STATE {
	ASLEEP,
	DEFENDING,
	ATTACKING,
}

enum FOCUS_ACTION {
	IDLE, # default: can move and attack
	EMOTING, # communicating, scared
	STUNNED,
	DODGE,
	DIVEOUT,
	DEAD,
	
	RETREATING,
	SEARCHING,
	INSPECTING,
	CHASING
}

# states from which the entity is available to start moving
# TODO: Real usage so far: states from which the entity is available to start chasing
const MOVABLE_FOCUS_ACTIONS = [
	FOCUS_ACTION.IDLE,
	FOCUS_ACTION.RETREATING,
	FOCUS_ACTION.SEARCHING,
	FOCUS_ACTION.INSPECTING,
	#FOCUS_ACTION.CHASING,
]

enum CUE_TYPE {
	SUSPICIUS, # gunshot, explosion, dead body
	DANGER, # dangerous object: grenade, projectile
	DAMAGED, # got damaged
	ENEMY_REPORTED, # some else saw the enemy
	ENEMY, # enemy spotted
}

class Cue:
	var id: int
	var type: CUE_TYPE
	var position: Vector3
	var timestamp: int
	var entity: EntityDetectable

static func create_cue(type: CUE_TYPE, position: Vector3, entity: EntityDetectable = null) -> Cue:
	var cue = Cue.new()
	cue.id = randi()
	cue.timestamp = Time.get_unix_time_from_system()
	cue.type = type
	cue.position = position
	cue.entity = entity
	return cue
