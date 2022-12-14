extends KinematicBody2D

var velocity = Vector2.ZERO
var spin: float = rand_range(0, PI/16)
var min_spin = PI/64

func _physics_process(delta):
	velocity = velocity.move_toward(Vector2.ZERO, 10)
	
	rotate(spin)
	if spin > min_spin:
		spin -= PI/128 * delta
	
	velocity = move_and_slide(velocity)
