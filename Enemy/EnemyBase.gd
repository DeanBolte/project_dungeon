extends KinematicBody2D

var ACCELERATION = 500
var MAX_VELOCITY = 300
var FRICTION = 200
var MAX_HEALTH = 1
var INVINCIBLE_TIME = 0.05
var RECOIL = 40

var playerDetectionZone
var wandererController

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var state = IDLE
var health = MAX_HEALTH
var invincible = 0

func _process(delta):
	if invincible > 0:
		invincible -= delta

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

func recoil(dir, value):
	velocity -= dir.normalized() * value

func set_health(value):
	health = clamp(value, 0, MAX_HEALTH)

func decrement_health(value = 1):
	if invincible <= 0:
		set_health(health - value)
		invincible = INVINCIBLE_TIME
