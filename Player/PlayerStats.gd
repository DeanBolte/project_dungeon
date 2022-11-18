extends Node

export(int) var max_health setget set_max_health
var health = max_health setget set_health

export(int) var max_clip setget set_max_clip
var clip = max_clip setget set_clip

signal no_health
signal health_changed(value)
signal max_health_changed(value)

signal no_clip
signal clip_changed(value)
signal max_clip_changed(value)

func _ready():
	self.health = max_health
	self.clip = max_clip

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
