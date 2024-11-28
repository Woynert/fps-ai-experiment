extends Node
class_name PelotonManager

static var _instance = null
var pelotones: Array[Peloton] = []


static func get_singleton() -> PelotonManager:
	if not _instance:
		_instance = PelotonManager.new()
	return _instance


func register(peloton: Peloton) -> int:
	pelotones.append(peloton)
	return pelotones.size() -1
	

func get_peloton(id: int) -> Peloton:
	if id > -1 && id < pelotones.size():
		return pelotones[id]
	return null
