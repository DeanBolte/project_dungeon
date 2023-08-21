extends Area2D

@onready var timer = $Timer
@onready var collisionShape = $CollisionShape2D

var invincible = false

func is_invincible():
	return invincible

func start_invincibility(time):
	invincible = true
	timer.start(time)
	
	collisionShape.disabled = true


func _on_Timer_timeout():
	invincible = false
	collisionShape.disabled = false
