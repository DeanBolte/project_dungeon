extends "res://Enemy/Common/RangedEnemyModel.gd"

# set enemy specific values
func _ready():
	# initialise
	playerDetectionZone = $PlayerDetectionZone
	wandererController = $WandererController
	
	ACCELERATION = 400
	MAX_VELOCITY = 200
	FRICTION = 200
	MAX_HEALTH = 3
	set_health(MAX_HEALTH)
	RECOIL = 200
	
	MOVE_TO_PLAYER = 210
	MOVE_AWAY_PLAYER = 190
	
	FIRE_RATE = 0.8
	CLIP_SIZE = 1
	RELOAD_TIME = 1
	
	MAX_DROPS = 4
	
	state = pick_rand_state([IDLE, WANDER])

func _on_HurtBox_body_entered(body):
	decrement_health(body.damage)
	recoil(-body.direction, RECOIL)

func _on_PlayerDetectionCycle_timeout():
	if playerDetectionZone.can_see_player():
		Agent.set_target_location(playerDetectionZone.player.global_position)
