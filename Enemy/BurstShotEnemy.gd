extends "res://Enemy/Common/RangedEnemyModel.gd"

# set enemy specific values
func _ready():
	# initialise
	playerDetectionZone = $PlayerDetectionZone
	wandererController = $WandererController
	
	ACCELERATION = 600
	MAX_VELOCITY = 250
	FRICTION = 200
	MAX_HEALTH = 4
	set_health(MAX_HEALTH)
	RECOIL = 300
	
	MOVE_TO_PLAYER = 210
	MOVE_AWAY_PLAYER = 190
	
	FIRE_RATE = 0.1
	CLIP_SIZE = 5
	RELOAD_TIME = 1.5
	
	MAX_DROPS = 6
	
	state = pick_rand_state([IDLE, WANDER])

func _on_HurtBox_body_entered(body):
	take_hit(body.damage * body.critical, body.direction)

func _on_PlayerDetectionCycle_timeout():
	if playerDetectionZone.can_see_player():
		Agent.set_target_location(playerDetectionZone.player.global_position)
