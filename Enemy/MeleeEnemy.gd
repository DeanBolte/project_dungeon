extends "res://Enemy/Common/MeleeEnemyModel.gd"

# set enemy specific values
func _ready():
	# initialise
	playerDetectionZone = $PlayerDetectionZone
	wandererController = $WandererController
	
	ACCELERATION = 500
	MAX_VELOCITY = 300
	FRICTION = 200
	MAX_HEALTH = 1
	PLAYER_SCORE_VALUE = 1
	set_health(MAX_HEALTH)
	
	MAX_DROPS = 2
	
	state = pick_rand_state([IDLE, WANDER])

func _on_HurtBox_body_entered(body):
	take_hit(body.damage * body.critical, body.direction)

func _on_PlayerDetectionCycle_timeout():
	if playerDetectionZone.can_see_player():
		Agent.set_target_position(playerDetectionZone.player.global_position)
