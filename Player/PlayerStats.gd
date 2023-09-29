extends Node

signal camera_stagger(value: Vector2)

signal no_health
signal health_changed(value)
signal max_health_changed(value)

signal clip_changed(value)
signal max_clip_changed(value)
signal ammo_count_changed(value)

signal reloading(value)

@export var STARTING_AMMO = 5

# player scores
var score: int = 0
var start_time: int = 0
var time_since_damaged: int = 0
var kills: int = 0
var hits_taken: int = 0

@export var max_health: int: set = set_max_health
var health = max_health: set = set_health

@export var max_clip: int: set = set_max_clip
var clip = max_clip: set = set_clip

enum AmmoType {
	STANDARD,
	SLUG
}
var selected_shot_type = AmmoType.STANDARD
var ammo_counts := Dictionary()

func _ready():
	initialise()

func initialise():
	self.health = max_health
	self.clip = max_clip
	self.score = 0
	self.start_time = Time.get_ticks_msec()
	self.hits_taken = 0
	
	set_ammo_count(AmmoType.STANDARD, STARTING_AMMO)

# health related calls
func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	max_health_changed.emit(max_health)

func set_health(value):
	health = value
	health_changed.emit(health)
	if(health <= 0):
		no_health.emit()

func decrement_health(value = 1):
	set_health(self.health - value)
	increment_hits_taken()

func increment_health(value: int = 1):
	if health < max_health:
		set_health(self.health + value)

# ammo related calls
func set_max_clip(value):
	max_clip = value
	self.clip = min(clip, max_clip)
	max_clip_changed.emit(max_clip)

func set_clip(value):
	clip = value
	clip_changed.emit(clip)
	update_ammo_ui()

func decrement_clip(value = 1):
	set_clip(self.clip - value)

func update_ammo_ui():
	if ammo_counts.has(selected_shot_type):
		ammo_count_changed.emit(ammo_counts[selected_shot_type])

func set_ammo_count(ammo_type: int, value: int):
	ammo_counts[ammo_type] = value
	update_ammo_ui()

func decrement_ammo_count(consumedShots: int = 1) -> int:
	if ammo_counts.has(selected_shot_type):
		var leftoverAmmo: int = ammo_counts[selected_shot_type] - consumedShots
		set_ammo_count(selected_shot_type, int(max(leftoverAmmo, 0)))
		return  max_clip + min(leftoverAmmo, 0)
	return 0

func increment_ammo_count(ammo_type: int, value: int = 1):
	if ammo_counts.has(ammo_type):
		ammo_counts[ammo_type] += value

func get_ammo_count():
	if has_ammo():
		return ammo_counts[selected_shot_type]
	return 0

func set_ammo_type(type: int):
	if type < 0:
		selected_shot_type = AmmoType.get(0)
	elif type > AmmoType.size() - 1:
		selected_shot_type = AmmoType.get(AmmoType.size() - 1)
	else:
		selected_shot_type = type

func increment_ammo_type(value: int = 1):
	set_ammo_type(selected_shot_type + value)

func decrement_ammo_type(value: int = 1):
	set_ammo_type(selected_shot_type - value)

func has_ammo() -> bool:
	return ammo_counts.has(selected_shot_type) && ammo_counts[selected_shot_type] > 0

func reload(duration: float, reload_speed: float):
	reloading.emit(duration, reload_speed)

func reload_clip():
	var newClip := decrement_ammo_count(max_clip)
	set_clip(newClip)
	

func increment_score(value: int = 1):
	score += value

func increment_kills(value: int = 1):
	kills += value

func enemy_defeated(score: int):
	increment_score(score + time_score_value())
	increment_kills()

func time_score_value() -> int:
	return int(time_since_damaged / 1000)

func increment_hits_taken():
	self.hits_taken += 1
	self.time_since_damaged = Time.get_ticks_msec() - start_time

func trigger_camera_stagger(staggerVector: Vector2):
	camera_stagger.emit(staggerVector)
