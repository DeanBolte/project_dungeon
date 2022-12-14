extends KinematicBody2D

onready var animationPlayer = $StateAnimationPlayer
onready var shotgunAnimationPlayer = $ShotgunAnimationPlayer
onready var hurtBox = $HurtBox
onready var shotgunSprite = $ShotgunSprite

export var ACCELERATION = 10000
export var MAX_VELOCITY = 400
export var FRICTION = 0.1
export var MIN_VELOCITY = 20

export var DODGE_VELOCITY = 800
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
var ShotgunShell = preload("res://Weapons/Shotgun/Animations/ShotgunShell.tscn")

var velocity = Vector2.ZERO
var aimingNormalVector

var shootCoolDown = SHOT_TIME
var reloading = false
var clip = CLIP_SIZE

func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	var _playerStatsError = PlayerStats.connect("no_health", self, "player_death")

func _physics_process(delta):
	# aim shotgun
	aimingNormalVector = (get_global_mouse_position() - global_position).normalized()
	shotgunSprite.position = aimingNormalVector * 32
	shotgunSprite.rotation = aimingNormalVector.angle() + PI/2
	
	# decrement i frame time
	if damage_cooldown > 0:
		damage_cooldown -= delta
	
	# toggle shot type
	if Input.is_action_just_pressed("toggle_shot"):
		if shot_type < shot_types - 1:
			shot_type += 1
		else:
			shot_type = 0
	
	if Input.is_action_just_pressed("player_reload") && clip < CLIP_SIZE:
		reload()
	
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
	velocity = velocity.limit_length(MAX_VELOCITY)
	
	# friction
	velocity = lerp(velocity, Vector2.ZERO, FRICTION)
	if velocity.length() <= MIN_VELOCITY:
		velocity = Vector2.ZERO

func calculate_dodge(_delta):
	velocity = velocity.normalized() * DODGE_VELOCITY
	animationPlayer.play("Dodge")

func calculate_attack(delta):
	if not reloading:
		PlayerStats.set_clip(clip)
		if Input.get_action_strength("player_shoot") && shootCoolDown <= 0:
			# match shot
			match shot_type:
				STANDARD:
					for _i in range(SHOT_COUNT):
						create_shot(StandardShot.instance())
				SLUG:
					create_shot(SlugShot.instance())
			
			
			if clip > 1:
				shootCoolDown = SHOT_TIME
				clip -= 1
			else:
				reload()
			
			# decrement UI ammo count
			PlayerStats.decrement_clip()
	if shootCoolDown > 0:
		shootCoolDown -= delta

func create_shells():
	for _s in range(2):
		var shellInst = ShotgunShell.instance()
		var noiseVector = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()
		shellInst.velocity = aimingNormalVector * -250 + noiseVector * 150
		shellInst.global_position = global_position + aimingNormalVector * 36
		get_parent().add_child(shellInst)

func create_shot(shotInst):
	var shootDirection = get_local_mouse_position()
	
	shootDirection = shootDirection.normalized()
	shootDirection.x += rand_range(-shotInst.ACCURACY,shotInst.ACCURACY)
	shootDirection.y += rand_range(-shotInst.ACCURACY,shotInst.ACCURACY)
	
	shotInst.global_position = global_position + aimingNormalVector * 40
	shotInst.direction = shootDirection
	get_parent().get_parent().add_child(shotInst)

func reload():
	reloading = true
	shotgunAnimationPlayer.play("Reload")

func reload_ended():
	reloading = false
	clip = CLIP_SIZE

func dodge_ended():
	state = MOVE

func player_death():
	get_tree().change_scene("res://MainMenu/Menu.tscn")

func _on_HurtBox_area_entered(_area):
	if damage_cooldown <= 0:
		PlayerStats.decrement_health()
		damage_cooldown = DAMAGE_INVINC_TIME
