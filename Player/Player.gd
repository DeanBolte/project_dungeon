extends KinematicBody2D

export var ACCELERATION = 20000
export var MAX_VELOCITY = 1000
export var FRICTION = 0.1
export var MIN_VELOCITY = 20

export var SHOOT_COOLDOWN = 0.5
export var SHOT_COUNT = 5

var health = 1

var shot = preload("res://Weapons/Shotgun/Shot.tscn")

var velocity = Vector2.ZERO

var shootCoolDown = SHOOT_COOLDOWN

func _ready():
	randomize()
	PlayerStats.connect("no_health", self, "queue_free")

func _physics_process(delta):
	# attack
	calculate_attack(delta)
	
	# movement
	calculate_movement(delta)
	
	velocity = move_and_slide(velocity)

# take player input and compute velocity
func calculate_movement(delta):
	# get input from player
	var hmove = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	var vmove = Input.get_action_strength("player_down") - Input.get_action_strength("player_up")
	
	# compute controlled player movement
	velocity.x += hmove * ACCELERATION * delta
	velocity.y += vmove * ACCELERATION * delta
	velocity = velocity.clamped(MAX_VELOCITY)
	
	# friction
	velocity = lerp(velocity, Vector2.ZERO, FRICTION)
	if velocity.length() <= MIN_VELOCITY:
		velocity = Vector2.ZERO

func calculate_attack(delta):
	if Input.get_action_strength("player_shoot") and shootCoolDown <= 0:
		for i in range(SHOT_COUNT):
			create_shot()
		
		shootCoolDown = SHOOT_COOLDOWN
	elif shootCoolDown > 0:
		shootCoolDown -= delta

func create_shot():
	var shootDirection = get_local_mouse_position()
	
	shootDirection = shootDirection.normalized()
	shootDirection.x += rand_range(-0.2,0.2)
	shootDirection.y += rand_range(-0.2,0.2)
	
	var shotInst = shot.instance()
	shotInst.global_position = global_position
	shotInst.direction = shootDirection
	get_parent().add_child(shotInst)



func _on_HurtBox_area_entered(area):
	PlayerStats.decrement_health()
