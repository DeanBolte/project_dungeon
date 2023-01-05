extends KinematicBody2D

# accessed member nodes
onready var animationPlayer := $StateAnimationPlayer
onready var shotgunAnimationPlayer := $ShotgunAnimationPlayer
onready var punchAnimationPlayer := $PunchAnimationPlayer
onready var hurtBox := $HurtBox
onready var shotgunSprite := $ShotgunSprite

# sound effects
onready var SFX := $SFX
onready var shotgunBlastSFX := $SFX/ShotgunBlast

# preloaded objects
var StandardShot = preload("res://Weapons/Shotgun/Standard.tscn")
var SlugShot = preload("res://Weapons/Shotgun/Slug.tscn")
var ShotgunShell = preload("res://Weapons/Shotgun/Animations/ShotgunShell.tscn")

# member constants
export var ACCELERATION = 10000
export var MAX_VELOCITY = 400
export var FRICTION = 0.1
export var MIN_VELOCITY = 20

export var DODGE_VELOCITY = 800
export var INVINCIBILE_TIME = 0.2

export var DAMAGE_INVINC_TIME = 0.3

export var RELOAD_TIME = 2
export var SHOT_TIME = 0.2
export var SHOT_COUNT = 5
export var CLIP_SIZE = 2
export var RELOAD_DECAY = 0.3

# enums
enum {
	MOVE,
	DODGE
}
var state = MOVE

var AmmoType = PlayerStats.AmmoType
var loaded_shot_type = AmmoType.STANDARD

# member variables
var damage_cooldown = DAMAGE_INVINC_TIME

var velocity := Vector2.ZERO
var aimingNormalVector := Vector2.ZERO

var shootCoolDown = 0
var reloading = false
var reload_time: float = 0
var clip: int = CLIP_SIZE setget set_clip

# member variable setters and getters
func set_clip(value: int):
	PlayerStats.set_clip(value)

# built in runtime functions
func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	var _playerStatsError = PlayerStats.connect("no_health", self, "player_death")

func _physics_process(delta):
	# aim shotgun
	aimingNormalVector = get_global_mouse_position() - global_position
	aimingNormalVector = aimingNormalVector.normalized()
	shotgunSprite.position = aimingNormalVector * 32
	shotgunSprite.rotation = aimingNormalVector.angle() + PI/2
	
	# decrement i frame time
	if damage_cooldown > 0:
		damage_cooldown -= delta
	
	# toggle shot type
	if Input.is_action_just_pressed("toggle_shot"):
		PlayerStats.increment_ammo_type()
	
	if Input.is_action_just_pressed("player_reload") && clip < CLIP_SIZE:
		reload()
	
	# attack
	calculate_shotgun(delta)
	calculate_punch(delta)
	
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

func calculate_punch(_delta: float):
	# perform punch
	if Input.is_action_just_pressed("player_punch"):
		punchAnimationPlayer.play("Punch")
	
	# aim punch
	$PunchBox.position = aimingNormalVector * 32

func calculate_shotgun(delta):
	PlayerStats.set_clip(clip)
	PlayerStats.update_ammo_ui()
	if not reloading:
		if Input.is_action_just_pressed("player_shoot") && shootCoolDown <= 0 && clip > 0:
			# shot sfx
			shotgunBlastSFX.play()
			
			# match shot
			match loaded_shot_type:
				AmmoType.STANDARD:
					for _i in range(SHOT_COUNT):
						create_shot(StandardShot.instance())
				AmmoType.SLUG:
					create_shot(SlugShot.instance())
			
			if clip > 0:
				shootCoolDown = SHOT_TIME
				clip -= 1
			else:
				pass # no ammo
	
	if shootCoolDown > 0:
		shootCoolDown -= delta

func create_shell():
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
	if not reloading:
		# initiate reload
		reloading = true
		# reload time is based on the clip size
		reload_time = RELOAD_TIME - (RELOAD_TIME / CLIP_SIZE) * clip
		
		# run animations
		var reload_speed: float = 1/reload_time
		PlayerStats.reload(reload_time, reload_speed)
		shotgunAnimationPlayer.play("Reload", 0.0, reload_speed)
	else:
		PlayerStats.reload(RELOAD_DECAY, 1)
		shotgunAnimationPlayer.advance(RELOAD_DECAY)

func reload_ended():
	# finalise reload
	reloading = false
	
	# update shot type
	loaded_shot_type = PlayerStats.selected_shot_type
	# reset clip
	clip = PlayerStats.decrement_ammo_count(PlayerStats.max_clip)

func dodge_ended():
	state = MOVE

func player_death():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://MainMenu/Menu.tscn")

func _on_HurtBox_area_entered(_area):
	if damage_cooldown <= 0:
		PlayerStats.decrement_health()
		damage_cooldown = DAMAGE_INVINC_TIME
