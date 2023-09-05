extends "res://Enemy/Common/EnemyModel.gd"

@export var FIRE_RATE = 0.1
@export var CLIP_SIZE = 5
@export var RELOAD_TIME = 2
@export var SHOT_RECOIL = 1

var fire_cooldown = FIRE_RATE
var clip_size = CLIP_SIZE

var shot = preload("res://Enemy/Common/Shots/EnemyShot.tscn")

# --- States ---
# CHASE
func chase_player(delta):
	var player = playerDetectionZone.player
	if player:
		# get close to player
		if not Agent.is_target_reached():
			var direction = global_position.direction_to(Agent.get_next_path_position())
			if global_position.distance_to(player.global_position) > MOVE_TO_PLAYER:
				velocity = velocity.move_toward(direction * MAX_VELOCITY, ACCELERATION)
			elif global_position.distance_to(player.global_position) < MOVE_AWAY_PLAYER:
				velocity = velocity.move_toward(-direction * MAX_VELOCITY, ACCELERATION)
			else:
				velocity = Vector2.ZERO
		
		# shoot player
		calculate_attack(player, delta)
	else:
		# if player cannot be found revert to idle
		state = IDLE

# Utility Functions
func calculate_attack(player, delta):
	if fire_cooldown <= 0:
		if clip_size > 0:
			create_shot(player)
			fire_cooldown = FIRE_RATE
			clip_size -= 1
		else:
			clip_size = CLIP_SIZE
			fire_cooldown = RELOAD_TIME
	else:
		fire_cooldown -= delta

func create_shot(player):
	var shootDirection: Vector2 = player.global_position - global_position
	
	shootDirection = shootDirection.normalized()
	shootDirection.x += randf_range(-0.2,0.2)
	shootDirection.y += randf_range(-0.2,0.2)
	
	var shotInst = shot.instantiate()
	shotInst.global_position = global_position
	shotInst.direction = shootDirection
	get_node('../../Bullets').add_child(shotInst)
	
	recoil(shootDirection.normalized(), SHOT_RECOIL)
