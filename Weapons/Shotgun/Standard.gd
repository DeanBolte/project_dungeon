extends "res://Weapons/Shotgun/Shot.gd"

func _ready():
	ACCURACY = 0.2
	SPEED = randf_range(1000, 1500)
	MAX_DAMAGE = 5
	damage = MAX_DAMAGE
	MIN_DAMAGE = 1
	DAMAGE_LOSS = 20

