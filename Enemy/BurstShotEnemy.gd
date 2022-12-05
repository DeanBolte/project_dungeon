extends "res://Enemy/Common/RangedEnemyModel.gd"

func _ready():
	# initialise
	playerDetectionZone = $PlayerDetectionZone
	wandererController = $WandererController
	
	ACCELERATION = 600
	MAX_VELOCITY = 250
	FRICTION = 200
	MAX_HEALTH = 4
	set_health(MAX_HEALTH)
	RECOIL = 200
	
	MOVE_TO_PLAYER = 210
	MOVE_AWAY_PLAYER = 190
	
	FIRE_RATE = 0.1
	CLIP_SIZE = 5
	RELOAD_TIME = 2
	
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

func _on_HurtBox_body_entered(body):
	decrement_health(body.damage)
	recoil(-body.direction, 400)

func _on_PlayerDetectionCycle_timeout():
	if playerDetectionZone.can_see_player():
		Agent.set_target_location(playerDetectionZone.player.global_position)
