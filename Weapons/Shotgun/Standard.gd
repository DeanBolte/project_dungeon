extends "res://Weapons/Shotgun/Shot.gd"

func _ready():
	ACCURACY = 0.2
	SPEED = rand_range(1500, 2000)
	MAX_DAMAGE = 5
	damage = MAX_DAMAGE
	MIN_DAMAGE = 1
	DAMAGE_LOSS = 20
