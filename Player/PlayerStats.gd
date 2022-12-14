extends Node

signal no_health
signal health_changed(value)
signal max_health_changed(value)

signal clip_changed(value)
signal max_clip_changed(value)

export(int) var max_health setget set_max_health
var health = max_health setget set_health

export(int) var max_clip setget set_max_clip
var clip = max_clip setget set_clip

enum {
	STANDARD,
	SLUG
}
var ammo_counts := Dictionary()

func _ready():
	initialise()

func initialise():
	self.health = max_health
	self.clip = max_clip
	
	ammo_counts[STANDARD] = 7

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

func set_ammo_count(ammo_type: int, value: int):
	ammo_counts[ammo_type] = value

func decrement_ammo_count(ammo_type: int, value: int = 1):
	if ammo_counts.has(ammo_type):
		var ammo_left = ammo_counts[ammo_type] - value
		if ammo_left >= 0:
			set_ammo_count(ammo_type, ammo_counts[ammo_type] - value)
			return value
		else:
			var ammo_available = ammo_counts[ammo_type]
			ammo_counts[ammo_type] = 0
			return ammo_available
	else:
		return 0
