extends "res://Enemy/Common/MeleeEnemyModel.gd"

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

func _on_HurtBox_body_entered(body):
	decrement_health(body.damage)
	recoil(-body.direction, 400)

func _on_PlayerDetectionCycle_timeout():
	if playerDetectionZone.can_see_player():
		Agent.set_target_location(playerDetectionZone.player.global_position)
