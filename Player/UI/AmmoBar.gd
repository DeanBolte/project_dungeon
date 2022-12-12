extends Control

const HEARTWIDTH = 32

onready var Clip = $Clip

var clip = 3 setget set_clip
var max_clip = 4 setget set_max_clip

func set_clip(value):
	clip = clamp(value, 0, max_clip)
	Clip.rect_size.x = clip * HEARTWIDTH

func set_max_clip(value):
	max_clip = max(value, 1)
	self.clip = min(clip, max_clip)

func _ready():
	# initialise clip
	self.max_clip = PlayerStats.max_clip
	self.clip = PlayerStats.clip
	
	# connect singals
# warning-ignore:return_value_discarded
	PlayerStats.connect("clip_changed", self, "set_clip")
# warning-ignore:return_value_discarded
	PlayerStats.connect("max_clip_changed", self, "set_max_clip")
