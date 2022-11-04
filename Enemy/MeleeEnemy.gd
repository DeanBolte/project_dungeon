extends KinematicBody2D

onready var Player = get_tree().root.get_child(1).get_node("Player")
onready var playerDetectionZone = $PlayerDetectionZone
onready var wandererController = $WandererController

export var ACCELERATION = 500
export var MAX_VELOCITY = 300
export var FRICTION = 200

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO

var state = IDLE

func _ready():
	state = pick_rand_state([IDLE, WANDER])

func _physics_process(delta):
	match state:
		IDLE:
			idle(delta)
		WANDER:
			wander(delta)
		CHASE:
			chase_player(delta)
	
	
	velocity = move_and_slide(velocity)

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func idle(delta):
	# check zone for player
	seek_player()
	
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	if(wandererController.get_time_left() == 0):
		update_wander()

func wander(delta):
	# check zone for player
	seek_player()
	
	if(wandererController.get_time_left() == 0):
		update_wander()
	
	accelerate_towards_point(wandererController.target_position, delta)

func update_wander():
	state = pick_rand_state([IDLE, WANDER])
	wandererController.start_wander_timer(rand_range(0, 1))

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_VELOCITY, ACCELERATION * delta)

func chase_player(delta):
	var player = playerDetectionZone.player
	if player:
		accelerate_towards_point(player.global_position, delta)
	else:
		state = IDLE

func pick_rand_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()


func _on_HurtBox_body_entered(body):
	queue_free()
