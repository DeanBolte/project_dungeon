extends "res://Weapons/Shotgun/Shot.gd"

func _ready():
	ACCURACY = 0.1
	SPEED = rand_range(2000, 2500)
	damage = 3

func collion_event(_collision):
	_collision.velocity = Vector2.ZERO
	
	queue_free()
