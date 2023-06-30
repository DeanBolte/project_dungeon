extends KinematicBody2D

export var MINIMUM_VELOCITY = 5
export var VELOCITY_DECAY = 8
export var ROTATION_SPEED = PI/4

var velocity = Vector2.ZERO

func _physics_process(_delta):
	velocity = velocity.move_toward(Vector2.ZERO, VELOCITY_DECAY)
	if velocity.length() <= MINIMUM_VELOCITY:
		queue_free()
	
	rotate(rand_range(0, ROTATION_SPEED))
	
	velocity = move_and_slide(velocity)
