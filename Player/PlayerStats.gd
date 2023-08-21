extends Node

signal no_health
signal health_changed(value)
signal max_health_changed(value)

signal clip_changed(value)
signal max_clip_changed(value)
signal ammo_count_changed(value)

signal reloading(value)

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
	
	set_ammo_count(AmmoType.STANDARD, 100)

# health related calls
func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if(health <= 0):
		emit_signal("no_health")

func decrement_health(value = 1):
	set_health(self.health - value)

func increment_health(value: int = 1):
	if health < max_health:
		set_health(self.health + value)

# ammo related calls
func set_max_clip(value):
	max_clip = value
	self.clip = min(clip, max_clip)
	emit_signal("max_clip_changed", max_clip)

func set_clip(value):
	clip = value
	emit_signal("clip_changed", clip)

func decrement_clip(value = 1):
	set_clip(self.clip - value)

func update_ammo_ui():
	if ammo_counts.has(selected_shot_type):
		emit_signal("ammo_count_changed", ammo_counts[selected_shot_type])

func set_ammo_count(ammo_type: int, value: int):
	ammo_counts[ammo_type] = value

func decrement_ammo_count(consumedShots: int = 1):
	if ammo_counts.has(selected_shot_type):
		var leftoverAmmo: int = ammo_counts[selected_shot_type] - consumedShots
		set_ammo_count(selected_shot_type, int(max(leftoverAmmo, 0)))
		return max_clip - min(leftoverAmmo, 0)
	else:
		return 0

func increment_ammo_count(ammo_type: int, value: int = 1):
	if ammo_counts.has(ammo_type):
		ammo_counts[ammo_type] += value

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

func reload(duration: float, reload_speed: float):
	emit_signal("reloading", duration, reload_speed)
