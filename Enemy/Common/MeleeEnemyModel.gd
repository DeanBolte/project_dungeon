extends "res://Enemy/Common/EnemyModel.gd"

# --- States ---
# CHASE
func chase_player(_delta):
	var player = playerDetectionZone.player
	if player:
		# get close to player
		var direction = global_position.direction_to(Agent.get_next_path_position())
		velocity = velocity.move_toward(direction * MAX_VELOCITY, ACCELERATION)
	else:
		state = IDLE
