extends Node
class_name IASensesManager

const THINK_TICK_DELAY: int = 60 / 15

var tick: int = 0
var senses_to_cull: Array[IASense] = []
@onready var common: IACommon = $".."

signal signal_cue(cue: IAModel.Cue)


func setup():
	for child in get_children():
		var sense = child as IASense
		if !sense:
			continue
		sense.setup(common.physic_manager)
		if sense is IASenseVision:
			senses_to_cull.append(sense)
		elif sense is IASenseHear:
			(sense as IASenseHear).signal_cue.connect(process_cue)


func _physics_process(delta):
	if tick % THINK_TICK_DELAY == 0:
		think()
	tick += 1


func think():
	for sense: IASense in senses_to_cull:
		var cues = sense.sense(common.state_manager.aim)
		for cue in cues:
			print("D: cue %s %s" % [cue.type, cue.position])
			signal_cue.emit(cue)


func process_cue(cue: IAModel.Cue):
	print("D: cue %s %s" % [cue.type, cue.position])
	signal_cue.emit(cue)
