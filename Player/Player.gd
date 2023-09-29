extends CharacterBody2D

# accessed member nodes
@onready var animationPlayer := $StateAnimationPlayer
@onready var shotgunAnimationPlayer := $ShotgunAnimationPlayer
@onready var punchAnimationPlayer := $PunchAnimationPlayer
@onready var hurtBox := $HurtBox
@onready var shotgunSprite := $ShotgunSprite
@onready var meleeSprite := $PunchBox/MeleeSprite
@onready var camera := $Camera2D

# sound effects
@onready var SFX := $SFX
@onready var shotgunBlastSFX := $SFX/ShotgunBlast

# preloaded objects
var StandardShot = preload("res://Weapons/Shotgun/Standard.tscn")
var SlugShot = preload("res://Weapons/Shotgun/Slug.tscn")
var ShotgunShell = preload("res://Weapons/Shotgun/Animations/ShotgunShell.tscn")

var DeathCardScene = "res://Scenes/death_card.tscn"

# member constants
@export var ACCELERATION = 8000
@export var MAX_VELOCITY = 600
@export var FRICTION = 0.1
@export var MIN_VELOCITY = 20

@export var DODGE_VELOCITY = 800
@export var DODGE_COOLDOWN = 0.4
@export var INVINCIBILE_TIME = 0.2

@export var DAMAGE_INVINC_TIME = 0.3

@export var RELOAD_TIME = 0.8
@export var MINIMUM_RELOAD_TIME = 0.1
@export var SHOT_TIME = 0.2
@export var SHOT_COUNT = 5
@export var CLIP_SIZE = 2

@export var ACCURATE_SHOT_FREQUENCY = 2
@export var ACCURATE_SHOT_BOOST = 4
@export var SHOT_CREATION_PLAYER_OFFSET = 40
@export var SHELL_EJECTION_VELOCITY = -150

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

var aimingNormalVector := Vector2.ZERO

var shootCoolDown = 0
var dodgeCoolDown = 0
var reloading = false
var reload_time: float = 0

# built in runtime functions
func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	var _playerStatsError = PlayerStats.connect("no_health", Callable(self, "player_death"))

func _physics_process(delta):
	# aim shotgun
	aimingNormalVector = get_global_mouse_position() - global_position
	aimingNormalVector = aimingNormalVector.normalized()
	shotgunSprite.position = aimingNormalVector * 32
	shotgunSprite.rotation = aimingNormalVector.angle() + PI/2
	meleeSprite.rotation = aimingNormalVector.angle() + PI/2
	
	# decrement i frame time
	if damage_cooldown > 0:
		damage_cooldown -= delta
	
	# toggle shot type
	if Input.is_action_just_pressed("toggle_shot"):
		PlayerStats.increment_ammo_type()
	
	if Input.is_action_just_pressed("player_reload") || PlayerStats.clip <= 0:
		reload()
	
	# attack
	if state != DODGE:
		calculate_shotgun(delta)
		calculate_punch(delta)
	
	match state:
		MOVE:
			# movement
			calculate_movement(delta)
		DODGE:
			calculate_dodge(delta)
	
	set_velocity(velocity)
	move_and_slide()
	velocity = velocity

# take player input and compute velocity
func calculate_movement(delta):
	# get input from player
	var hmove = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	var vmove = Input.get_action_strength("player_down") - Input.get_action_strength("player_up")
	
	if Input.is_action_just_pressed("player_dodge") && dodgeCoolDown <= 0:
		state = DODGE
	elif dodgeCoolDown > 0:
		dodgeCoolDown -= delta
	
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
	hurtBox.start_invincibility(INVINCIBILE_TIME)
	animationPlayer.play("Dodge", -1, 1/INVINCIBILE_TIME)

func calculate_punch(_delta: float):
	# perform punch
	if Input.is_action_just_pressed("player_punch") && not reloading:
		punchAnimationPlayer.play("Punch")
	
	# aim punch
	$PunchBox.position = aimingNormalVector * 32

func calculate_shotgun(delta):
	if not reloading:
		if Input.is_action_just_pressed("player_shoot") && shootCoolDown <= 0 && PlayerStats.clip > 0:
			# shot sfx
			shotgunBlastSFX.play()
			
			# match shot
			match loaded_shot_type:
				AmmoType.STANDARD:
					for index in range(SHOT_COUNT):
						create_shot(StandardShot.instantiate(), index)
				AmmoType.SLUG:
					create_shot(SlugShot.instantiate())
			
			shootCoolDown = SHOT_TIME
			PlayerStats.decrement_clip()
	
	if shootCoolDown > 0:
		shootCoolDown -= delta

func create_shell():
	var shellInst = ShotgunShell.instantiate()
	var noiseVector = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	shellInst.velocity = (aimingNormalVector + noiseVector) * SHELL_EJECTION_VELOCITY
	shellInst.global_position = global_position + aimingNormalVector * 36
	get_parent().add_child(shellInst)

func create_shot(shotInst: Node, shotIndex: int = 0):
	if shotIndex % ACCURATE_SHOT_FREQUENCY == 0:
		shotInst.ACCURACY = shotInst.ACCURACY / ACCURATE_SHOT_BOOST
	
	var shootDirection = get_local_mouse_position().normalized()
	shootDirection.x += randf_range(-shotInst.ACCURACY, shotInst.ACCURACY)
	shootDirection.y += randf_range(-shotInst.ACCURACY, shotInst.ACCURACY)
	
	shotInst.global_position = global_position + aimingNormalVector * SHOT_CREATION_PLAYER_OFFSET
	shotInst.direction = shootDirection
	get_parent().get_parent().add_child(shotInst)

func reload():
	if not reloading && PlayerStats.clip < CLIP_SIZE && PlayerStats.has_ammo():
		# initiate reload
		reloading = true
		# reload time is based on the clip size
		reload_time = RELOAD_TIME - (RELOAD_TIME / CLIP_SIZE) * PlayerStats.clip
		
		# run animations
		var reload_speed: float = 1/max(reload_time, MINIMUM_RELOAD_TIME)
		PlayerStats.reload(reload_time, reload_speed)
		shotgunAnimationPlayer.play("Reload", 0.0, reload_speed)

func reload_ended():
	# finalise reload
	reloading = false
	
	# update shot type
	loaded_shot_type = PlayerStats.selected_shot_type
	# reset clip
	PlayerStats.reload_clip()

func dodge_ended():
	state = MOVE
	dodgeCoolDown = DODGE_COOLDOWN

func player_death():
# warning-ignore:return_value_discarded
	get_tree().change_scene_to_file(DeathCardScene)

func _on_HurtBox_area_entered(area):
	if damage_cooldown <= 0:
		camera.moveShakeOffsetVector((global_position - area.global_position) * 4)
		PlayerStats.decrement_health()
		damage_cooldown = DAMAGE_INVINC_TIME
