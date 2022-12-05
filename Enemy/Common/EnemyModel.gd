extends KinematicBody2D

onready var Agent: NavigationAgent2D = $NavigationAgent2D

# enemy stats (modified in ready functions for each individual)
# static otherwise but not enforced
var ACCELERATION = 500
var MAX_VELOCITY = 300
var FRICTION = 200
var MAX_HEALTH = 1
var INVINCIBLE_TIME = 0.05
var RECOIL = 40
var MOVE_TO_PLAYER = 210
var MOVE_AWAY_PLAYER = 190

# important nodes
var Nav
var playerDetectionZone
var wandererController

# enum for all possible enemy states
enum {
	IDLE,
	WANDER,
	CHASE
}
var state = IDLE

# member data
var velocity = Vector2.ZERO
var health = MAX_HEALTH
var invincible = 0 # seconds of invunrability

# run every physics frame (try to avoid using this)
func _physics_process(delta):
	# decay invincibility
	if invincible > 0:
		invincible -= delta
	
	# check health
	if health <= 0:
		queue_free()
	
	match state:
		IDLE:
			idle(delta)
		WANDER:
			wander(delta)
		CHASE:
			chase_player(delta)
	
	velocity = move_and_slide(velocity)

# --- States ---
# IDLE
func idle(_delta):
	# check zone for player
	seek_player()
	
	velocity = Vector2.ZERO
	
	if(wandererController.get_time_left() == 0):
		update_wander()

# a generic player seeking function
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		
		Agent.set_target_location(playerDetectionZone.player.global_position)

# WANDER
func wander(delta):
	# check zone for player
	seek_player()
	
	if(wandererController.get_time_left() == 0):
		update_wander()
	
	accelerate_towards_point(wandererController.target_position, MAX_VELOCITY, ACCELERATION * delta)

func update_wander():
	state = pick_rand_state([IDLE, WANDER])
	wandererController.start_wander_timer(rand_range(0, 1))

# CHASE
func chase_player(_delta):
	var player = playerDetectionZone.player
	if player:
		# get close to player
		var direction = global_position.direction_to(Agent.get_next_location())
		velocity = velocity.move_toward(direction * MAX_VELOCITY, ACCELERATION)
	else:
		state = IDLE

# --- Utiliy Functions ---
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

func initialise_nav(nav):
	Nav = nav
	Agent.set_navigation(Nav)

