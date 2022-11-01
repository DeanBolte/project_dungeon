extends KinematicBody2D

var SPEED = rand_range(1500, 2000)
var direction = Vector2.ZERO

func _physics_process(delta):
	var collision = move_and_collide(direction * SPEED * delta)
	
	if collision:
		queue_free()
