extends KinematicBody2D

var velocity = Vector2.ZERO

func _physics_process(_delta):
	velocity = velocity.move_toward(Vector2.ZERO, 10)
	if velocity.length() <= 10:
		queue_free()
	
	rotate(rand_range(0, PI/4))
	
	velocity = move_and_slide(velocity)
