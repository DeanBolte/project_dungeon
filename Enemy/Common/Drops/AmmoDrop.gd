extends KinematicBody2D

export var MAX_VELOCITY = 400
export var ACCELERATION = 100

var velocity = Vector2.ZERO
var spin: float = rand_range(0, PI/16)
var min_spin = PI/64

var Player = null

func _physics_process(delta):
	# slow down
	velocity = velocity.move_toward(Vector2.ZERO, 10)
	
	# move towards player if in range
	if Player:
		var direction = global_position.direction_to(Player.position)
		velocity = velocity.move_toward(direction * MAX_VELOCITY, ACCELERATION)
	
	rotate(spin)
	if spin > min_spin:
		spin -= PI/128 * delta
	
	velocity = move_and_slide(velocity)


func _on_PlayerDetectionArea_body_entered(body):
	Player = body

func _on_PlayerDetectionArea_body_exited(body):
	Player = null
