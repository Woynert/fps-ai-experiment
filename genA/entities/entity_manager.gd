extends Node
class_name EntityManager

static var _instance = null
var entities: Array[EntityDetectable] = []


static func get_singleton() -> EntityManager:
	if not _instance:
		_instance = EntityManager.new()
	return _instance


## registers entity
## @arg {Node} node to register as entity
## @return {int} entity's asigned id  
func register(entity: Node) -> int:
	entities.append(entity)
	return entities.size() -1


func get_entity(entity_id: int) -> Node:
	if entities.size() > entity_id && entity_id >= 0:
		return entities[entity_id]
	return null
