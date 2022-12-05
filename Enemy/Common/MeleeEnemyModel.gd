extends "res://Enemy/Common/EnemyModel.gd"

func chase_player(_delta):
	var player = playerDetectionZone.player
	if player:
		# get close to player
		var direction = global_position.direction_to(Agent.get_next_location())
		velocity = velocity.move_toward(direction * MAX_VELOCITY, ACCELERATION)
	else:
		state = IDLE
