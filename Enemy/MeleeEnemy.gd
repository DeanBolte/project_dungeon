extends "res://Enemy/EnemyBase.gd"

func _ready():
	# initialise
	playerDetectionZone = $PlayerDetectionZone
	wandererController = $WandererController
	
	ACCELERATION = 500
	MAX_VELOCITY = 300
	FRICTION = 200
	MAX_HEALTH = 1
	set_health(MAX_HEALTH)
	
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
		accelerate_towards_point(player.global_position, MAX_VELOCITY, ACCELERATION * delta)
	else:
		state = IDLE


func _on_HurtBox_body_entered(body):
	decrement_health()
	recoil(-body.direction, 400)
