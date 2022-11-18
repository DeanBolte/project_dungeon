extends KinematicBody2D

var ACCURACY = 0.2
var SPEED = rand_range(1500, 2000)
var MAX_DAMAGE = 1
var MIN_DAMAGE = 1
var DAMAGE_LOSS = 1 # damage loss per second

var direction = Vector2.ZERO
var damage = MAX_DAMAGE

func _physics_process(delta):
	# reduce damage of shot
	if damage > MIN_DAMAGE:
		damage = max(damage - delta * DAMAGE_LOSS, MIN_DAMAGE)
	
	# move bullet and check for collisions
	var collision = move_and_collide(direction * SPEED * delta)
	
	if collision:
		collision_event(collision)

func collision_event(_collision):
	queue_free()
