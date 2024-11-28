extends Node
class_name IAHearingManager

static var _instance = null
signal signal_sound(cue: IAModel.Cue)


static func get_singleton() -> IAHearingManager:
	if not _instance:
		_instance = IAHearingManager.new()
	return _instance


func report_sound(cue: IAModel.Cue):
	print("D: IAHearingManager: Sound reported")
	signal_sound.emit(cue)
