extends Camera2D

@export var CAMERA_OFFSET_SCALE = 4
@export var MIN_SHAKE_OFFSET = 5
@export var SCREEN_SHAKE_MODIFIER = 10

@onready var Player = $".."

var shakeOffsetVector: Vector2 = Vector2.ZERO

func _ready():
	PlayerStats.connect("camera_stagger", moveShakeOffsetVector)

func _process(_delta: float) -> void:
	var centreOffset: Vector2 = (get_global_mouse_position() - Player.global_position)
	var newCameraPosition = Player.global_position + centreOffset / CAMERA_OFFSET_SCALE
	
	if shakeOffsetVector.length() < MIN_SHAKE_OFFSET:
		shakeOffsetVector = Vector2.ZERO
	else:
		shakeOffsetVector = shakeOffsetVector.move_toward(-shakeOffsetVector, SCREEN_SHAKE_MODIFIER)
	
	global_position = newCameraPosition + shakeOffsetVector

func moveShakeOffsetVector(bumpVector: Vector2):
	shakeOffsetVector = shakeOffsetVector + bumpVector
