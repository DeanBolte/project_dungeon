extends "res://Enemy/EnemyBase.gd"

export var DISTANCE_FROM_PLAYER = 200

export var FIRE_RATE = 0.8

var fire_cooldown = FIRE_RATE

var shot = preload("res://Enemy/EnemyShot.tscn")

func _ready():
	# initialise
	playerDetectionZone = $PlayerDetectionZone
	wandererController = $WandererController
	
	ACCELERATION = 500
	MAX_VELOCITY = 300
	FRICTION = 200
	MAX_HEALTH = 2
	set_health(MAX_HEALTH)
	RECOIL = 200
	
	state = pick_rand_state([IDLE, WANDER])

func _physics_process(delta):
	# check health
	if health <= 0:
		queue_free()
	
	match state:
		IDLE:
			idle(delta)
		WANDER:
			wander(delta)
		CHASE:
			chase_player(delta)
	
	velocity = move_and_slide(velocity)

func chase_player(delta):
	var player = playerDetectionZone.player
	if player:
		# get close to player
		var direction = player.global_position - global_position
		var target_position = player.global_position - direction.normalized() * DISTANCE_FROM_PLAYER
		accelerate_towards_point(target_position, MAX_VELOCITY, ACCELERATION * delta)
		
		# shoot player
		calculate_attack(player, delta)
	else:
		# if player cannot be found revert to idle
		state = IDLE

func calculate_attack(player, delta):
	if fire_cooldown <= 0:
		create_shot(player)
		fire_cooldown = FIRE_RATE
	else:
		fire_cooldown -= delta

func create_shot(player):
	var shootDirection = player.global_position - global_position
	
	shootDirection = shootDirection.normalized()
	shootDirection.x += rand_range(-0.2,0.2)
	shootDirection.y += rand_range(-0.2,0.2)
	
	var shotInst = shot.instance()
	shotInst.global_position = global_position
	shotInst.direction = shootDirection
	get_parent().add_child(shotInst)
	
	recoil(shootDirection, RECOIL)

func _on_HurtBox_body_entered(body):
	decrement_health(body.damage)
	recoil(-body.direction, 400)
