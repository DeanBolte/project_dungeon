extends KinematicBody2D

onready var animationPlayer = $AnimationPlayer
onready var hurtBox = $HurtBox

export var ACCELERATION = 20000
export var MAX_VELOCITY = 500
export var FRICTION = 0.1
export var MIN_VELOCITY = 20

export var DODGE_VELOCITY = 1000
export var INVINCIBILE_TIME = 0.2

export var DAMAGE_INVINC_TIME = 0.3

export var RECHARGE_TIME = 1
export var SHOT_TIME = 0.2
export var SHOT_COUNT = 5
export var CLIP_SIZE = 2

enum {
	MOVE,
	DODGE
}
var state = MOVE

enum {
	STANDARD,
	SLUG
}
var shot_type = STANDARD
var shot_types = 2

var health = 1
var damage_cooldown = DAMAGE_INVINC_TIME

var StandardShot = preload("res://Weapons/Shotgun/Standard.tscn")
var SlugShot = preload("res://Weapons/Shotgun/Slug.tscn")

var velocity = Vector2.ZERO

var shootCoolDown = SHOT_TIME
var clip = CLIP_SIZE

func _ready():
	randomize()
	PlayerStats.connect("no_health", self, "queue_free")

func _physics_process(delta):
	# decrement i frame time
	if damage_cooldown > 0:
		damage_cooldown -= delta
	
	# toggle shot type
	if Input.is_action_just_pressed("toggle_shot"):
		if shot_type < shot_types - 1:
			shot_type += 1
		else:
			shot_type = 0
		
		shootCoolDown = RECHARGE_TIME
		clip = CLIP_SIZE
	
	# attack
	calculate_attack(delta)
	
	match state:
		MOVE:
			# movement
			calculate_movement(delta)
		DODGE:
			calculate_dodge(delta)
	
	velocity = move_and_slide(velocity)

# take player input and compute velocity
func calculate_movement(delta):
	# get input from player
	var hmove = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	var vmove = Input.get_action_strength("player_down") - Input.get_action_strength("player_up")
	
	if Input.is_action_just_pressed("player_dodge"):
		state = DODGE
		hurtBox.start_invincibility(INVINCIBILE_TIME)
	
	# compute controlled player movement
	velocity.x += hmove * ACCELERATION * delta
	velocity.y += vmove * ACCELERATION * delta
	velocity = velocity.clamped(MAX_VELOCITY)
	
	# friction
	velocity = lerp(velocity, Vector2.ZERO, FRICTION)
	if velocity.length() <= MIN_VELOCITY:
		velocity = Vector2.ZERO

func calculate_dodge(delta):
	velocity = velocity.normalized() * DODGE_VELOCITY
	animationPlayer.play("Dodge")

func calculate_attack(delta):
	if Input.get_action_strength("player_shoot") and shootCoolDown <= 0:
		match shot_type:
			STANDARD:
				for i in range(SHOT_COUNT):
					create_shot(StandardShot.instance())
			SLUG:
				create_shot(SlugShot.instance())
		
		
		if clip > 1:
			shootCoolDown = SHOT_TIME
			clip -= 1
		else:
			shootCoolDown = RECHARGE_TIME
			clip = CLIP_SIZE
	elif shootCoolDown > 0:
		shootCoolDown -= delta

func create_shot(shotInst):
	var shootDirection = get_local_mouse_position()
	
	shootDirection = shootDirection.normalized()
	shootDirection.x += rand_range(-shotInst.ACCURACY,shotInst.ACCURACY)
	shootDirection.y += rand_range(-shotInst.ACCURACY,shotInst.ACCURACY)
	
	shotInst.global_position = global_position
	shotInst.direction = shootDirection
	get_parent().add_child(shotInst)

func dodge_ended():
	state = MOVE


func _on_HurtBox_area_entered(area):
	if damage_cooldown <= 0:
		PlayerStats.decrement_health()
		damage_cooldown = DAMAGE_INVINC_TIME
