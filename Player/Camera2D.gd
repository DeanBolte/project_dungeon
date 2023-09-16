extends Camera2D

@export var CAMERA_OFFSET_SCALE = 4

@onready var Player = $".."

func _physics_process(_delta: float) -> void:
	var centreOffset: Vector2 = (get_global_mouse_position() - Player.global_position)
	global_position = Player.global_position + centreOffset / CAMERA_OFFSET_SCALE
