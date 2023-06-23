extends Camera2D

export var CAMERA_OFFSET_SCALE = 20

onready var Player = $".."

func _physics_process(_delta: float) -> void:
	var centreOffset: Vector2 = (get_global_mouse_position() - Player.global_position)
	var cameraOffset: Vector2 = centreOffset.normalized() * sqrt(centreOffset.length() * CAMERA_OFFSET_SCALE)
	global_position = Player.global_position + cameraOffset
