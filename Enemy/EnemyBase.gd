extends KinematicBody2D

var ACCELERATION = 500
var MAX_VELOCITY = 300
var FRICTION = 200

var playerDetectionZone
var wandererController

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var state = IDLE

func seek_player(playerDetectionZone):
	if playerDetectionZone.can_see_player():
		state = CHASE

func idle(delta):
	# check zone for player
	seek_player(playerDetectionZone)
	
	velocity = Vector2.ZERO
	
	if(wandererController.get_time_left() == 0):
		update_wander()

func wander(delta):
	# check zone for player
	seek_player(playerDetectionZone)
	
	if(wandererController.get_time_left() == 0):
		update_wander()
	
	accelerate_towards_point(wandererController.target_position, MAX_VELOCITY, ACCELERATION * delta)

func update_wander():
	state = pick_rand_state([IDLE, WANDER])
	wandererController.start_wander_timer(rand_range(0, 1))

func accelerate_towards_point(point, speed, acceleration):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * speed, acceleration)

func pick_rand_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
