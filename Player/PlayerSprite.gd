extends Sprite2D

@export var Player: CharacterBody2D

@onready var LeftHandSprite := $LeftHand
@onready var RightHandSprite := $RightHand

@onready var AnimationReset := $AnimationReset

@export var NOISE_VECTOR_UPDATE_DELAY = 25
@export var HAND_DISTANCE_RADIANS = PI/4
@export var HAND_NOISE_SCALE = 10
@export var HAND_PUNCH_DISTANCE = 10
@export var ANIMATION_RESET_DELAY = 0.3

var handNoiseVector := Vector2.ZERO
var noiseVectorAwait := 0
var handDistanceRadians = HAND_DISTANCE_RADIANS
var leftHandOffset := Vector2.ZERO
var rightHandOffset := Vector2.ZERO

var aimingNormalVector := Vector2.ZERO

func _physics_process(delta):
	# calculate inputs
	aimingNormalVector = get_global_mouse_position() - global_position
	aimingNormalVector = aimingNormalVector.normalized()
	
	move_hands(delta)

func move_hands(delta):
	# generate noise
	if noiseVectorAwait <= 0:
		handNoiseVector = Vector2(randf() * HAND_NOISE_SCALE, randf() * HAND_NOISE_SCALE)
		noiseVectorAwait = NOISE_VECTOR_UPDATE_DELAY
	else:
		noiseVectorAwait -= delta
	
	# calculate vectors
	var handCentralPositon = aimingNormalVector * 32
	var leftHandPosition = handCentralPositon.rotated(-handDistanceRadians) + handNoiseVector.reflect(aimingNormalVector)
	var rightHandPosition = handCentralPositon.rotated(handDistanceRadians) + handNoiseVector
	
	# apply vectors
	LeftHandSprite.position = lerp(LeftHandSprite.position, leftHandPosition, delta * 10)
	RightHandSprite.position = lerp(RightHandSprite.position, rightHandPosition, delta * 10)
	LeftHandSprite.rotation = lerp_angle(LeftHandSprite.rotation, aimingNormalVector.angle() + PI/2, delta * 10)
	RightHandSprite.rotation = lerp_angle(RightHandSprite.rotation, aimingNormalVector.angle() + PI/2, delta * 10)

func on_spell_cast():
	handDistanceRadians = 0
	AnimationReset.play("ResetSpellCast", -1, 1/ANIMATION_RESET_DELAY)

func on_spell_cast_over():
	handDistanceRadians = HAND_DISTANCE_RADIANS
