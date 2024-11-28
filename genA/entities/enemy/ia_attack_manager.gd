extends Node
class_name IAAttackManager


@onready var common: IACommon = $".."
var last_time_attack: int
const ATTACK_RECOVER = 1000


func ready_to_attack() -> bool:
	var curr_time = Time.get_ticks_msec()
	return curr_time > (last_time_attack + ATTACK_RECOVER)


func attack(dir_euler: Vector3) -> void:
	print("IAAttackManager, trying to attack")
	var curr_time = Time.get_ticks_msec()
	last_time_attack = curr_time
	
	DebugProjectile.spawn(get_tree().root, common.physic_manager.get_eyes_position(), dir_euler) 
