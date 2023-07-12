extends KinematicBody2D


var DestructionSoundPlayer = preload("res://Weapons/Shotgun/Animations/DestructionSoundPlayer.tscn")

var ACCURACY = 0.15
var SPEED = rand_range(1000, 1500)
var MAX_DAMAGE = 1
var MIN_DAMAGE = 1
var DAMAGE_LOSS = 1 # damage loss per second
var CRIT_TIME = 0.05
var MAX_LIFETIME = 5 # seconds

var direction = Vector2.ZERO
var damage = MAX_DAMAGE
var crit_timer = CRIT_TIME
var critical = 2

var lifetime = MAX_LIFETIME

func _physics_process(delta):
	# decay lifetime
	lifetime -= delta
	if lifetime < 0:
		collision_event()
	
	# decay crit
	if crit_timer <= 0:
		critical = 1
	else:
		crit_timer -= delta
	
	# reduce damage of shot
	if damage > MIN_DAMAGE:
		damage = max(damage - delta * DAMAGE_LOSS, MIN_DAMAGE)
	
	# move bullet and check for collisions
	var _velocity = move_and_slide(direction * SPEED)
	if get_slide_count() > 0:
		collision_event()

func collision_event():
	get_parent().add_child(DestructionSoundPlayer.instance())
	queue_free()
