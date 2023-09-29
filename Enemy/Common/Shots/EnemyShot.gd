extends CharacterBody2D

var SPEED = randf_range(500, 700)
var direction = Vector2.ZERO

func _physics_process(delta):
	var collision = move_and_collide(direction * SPEED * delta)
	
	if collision:
		queue_free()
