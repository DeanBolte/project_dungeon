extends "res://Enemy/EnemyBase.gd"

func _ready():
	# initialise
	playerDetectionZone = $PlayerDetectionZone
	wandererController = $WandererController
	
	ACCELERATION = 500
	MAX_VELOCITY = 300
	FRICTION = 200
	
	state = pick_rand_state([IDLE, WANDER])

func _physics_process(delta):
	match state:
		IDLE:
			idle(delta)
		WANDER:
			wander(delta)
		CHASE:
			chase_player(delta)
	
	velocity = move_and_slide(velocity)

func idle(delta):
	# check zone for player
	seek_player(playerDetectionZone)
	
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	if(wandererController.get_time_left() == 0):
		update_wander()

func chase_player(delta):
	var player = playerDetectionZone.player
	if player:
		accelerate_towards_point(player.global_position, MAX_VELOCITY, ACCELERATION * delta)
	else:
		state = IDLE


func _on_HurtBox_body_entered(body):
	queue_free()
