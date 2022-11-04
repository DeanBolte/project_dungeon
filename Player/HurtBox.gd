extends Area2D

onready var timer = $Timer

var invincible = false

func is_invincible():
	return invincible

func start_invincibility(time):
	invincible = true
	timer.start(time)


func _on_Timer_timeout():
	invincible = false
