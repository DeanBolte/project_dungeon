extends KinematicBody2D

onready var Agent: NavigationAgent2D = $NavigationAgent2D
onready var DamageEffects: Particles2D = $DamageEffects

var ammo_drop = preload("res://Enemy/Common/Drops/AmmoDrop.tscn")
var health_drop = preload("res://Enemy/Common/Drops/HealthDrop.tscn")

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
var MAX_DROPS = 3
var MAX_STUNNED_TIME = 0.8

# important nodes
var playerDetectionZone
var wandererController

# enum for all possible enemy states
enum {
	IDLE,
	WANDER,
	STUNNED,
	CHASE,
	DEAD
}
var state = IDLE
var stunned_timer: float = 0.0

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
		state = DEAD
	
	match state:
		IDLE:
			idle(delta)
		WANDER:
			wander(delta)
		STUNNED:
			stunned(delta)
		CHASE:
			chase_player(delta)
		DEAD:
			death()
	
	velocity = move_and_slide(velocity)
	
	# check for wall slam
	if get_slide_count() > 0:
		var collisions = get_slide_collision(0)
		if collisions:
			if velocity.length() > MAX_VELOCITY / 2 && state == STUNNED:
				take_hit(velocity.length(), velocity.normalized())

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

# STUNNED
func stunned(delta: float):
	# slow down
	velocity = velocity.move_toward(Vector2.ZERO, 50)
	
	# stunned timer
	if stunned_timer > 0:
		stunned_timer -= delta
	else:
		state = IDLE

# CHASE
func chase_player(_delta):
	var player = playerDetectionZone.player
	if player:
		# get close to player
		Agent.set_target_location(player.position)
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

func recoil(dir: Vector2, value: float):
	velocity -= dir * value

func set_health(value):
	health = clamp(value, 0, MAX_HEALTH)

func decrement_health(value = 1):
	set_health(health - value)

func take_hit(damage: float, direction: Vector2):
	# check if enemy can take damage
	if invincible <= 0:
		# recoil enemy
		recoil(-direction, damage * RECOIL)
		
		# take damage and add invicibility frames
		decrement_health(damage)
		invincible = INVINCIBLE_TIME
		state = STUNNED
		stunned_timer = MAX_STUNNED_TIME
		
		# create blood effect
		var material: ParticlesMaterial = DamageEffects.get_process_material()
		material.direction = Vector3(direction.x, direction.y, 0).normalized()
		DamageEffects.restart()

func death():
	# slow down
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION/2)
	
	# destroy
	if DamageEffects and not DamageEffects.is_emitting():
		# spawn loot
		generate_drops()
		
		# delete enemy instance
		queue_free()

func generate_drops():
	for _i in randi() % MAX_DROPS:
		var chance = randi() % 100
		if chance < 30:
			spawn_drop(health_drop)
		else:
			spawn_drop(ammo_drop)

func spawn_drop(packed_drop):
	var launch_vector = Vector2.ZERO
	var max_speed = 500
	launch_vector.x += rand_range(-max_speed,max_speed)
	launch_vector.y += rand_range(-max_speed,max_speed)
	
	var dropInst = packed_drop.instance()
	dropInst.global_position = global_position
	dropInst.velocity = launch_vector
	get_parent().add_child(dropInst)
