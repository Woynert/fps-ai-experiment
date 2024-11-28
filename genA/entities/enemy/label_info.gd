extends Label3D

@onready var common: IACommon = $"../.."


func _physics_process(delta: float) -> void:
	text = """alert_state %s
	current_action %s
	""" % [
		enum_name(IAModel.ALERT_STATE, common.state_manager.alert_state),
		enum_name(IAModel.FOCUS_ACTION, common.state_manager.current_action),
	]
	

static func enum_name(p_enum, value: int) -> String:
	return p_enum.keys()[value]
