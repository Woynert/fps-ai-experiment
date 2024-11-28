extends Node
class_name IACommon

@export var _path_state_manager: NodePath
@onready var state_manager: IAStateManager = get_node(_path_state_manager)

@export var _path_physic_manager: NodePath
@onready var physic_manager: IAPhysicManager = get_node(_path_physic_manager)

@export var _path_senses_manager: NodePath
@onready var senses_manager: IASensesManager = get_node(_path_senses_manager)

@export var _path_logic_manager: NodePath
@onready var logic_manager: IALogicManager = get_node(_path_logic_manager)

@export var _path_attack_manager: NodePath
@onready var attack_manager: IAAttackManager = get_node(_path_attack_manager)

@export var _path_sense_vision: NodePath
@onready var sense_vision: IASenseVision = get_node(_path_sense_vision)

func _ready():
	# state manager setup is done externally
	senses_manager.setup()
	logic_manager.setup()
