extends CharacterBody2D

@export var MINIMUM_VELOCITY = 5
@export var VELOCITY_DECAY = 8
@export var ROTATION_SPEED = PI/4

func _physics_process(_delta):
	velocity = velocity.move_toward(Vector2.ZERO, VELOCITY_DECAY)
	if velocity.length() <= MINIMUM_VELOCITY:
		queue_free()
	
	rotate(randf_range(0, ROTATION_SPEED))
	
	set_velocity(velocity)
	move_and_slide()
	velocity = velocity
