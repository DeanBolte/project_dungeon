extends CharacterBody2D

@export var MAX_VELOCITY = 800
@export var ACCELERATION = 100
@export var SPIN_DECAY = PI/128
@export var VELOCITY_DECAY = 10

var spin: float = randf_range(0, PI/16)
var min_spin = PI/64

var Player = null

func _physics_process(delta: float):
	# slow down
	velocity = velocity.move_toward(Vector2.ZERO, VELOCITY_DECAY)
	
	# move towards player if in range
	if Player:
		var direction = global_position.direction_to(Player.position)
		velocity = velocity.move_toward(direction * MAX_VELOCITY, ACCELERATION)
	
	rotate(spin)
	if spin > min_spin:
		spin -= SPIN_DECAY * delta
	
	set_velocity(velocity)
	move_and_slide()
	velocity = velocity
