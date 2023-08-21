extends Control

const HEARTWIDTH = 32

@onready var Clip = $Clip
@onready var AmmoCount = $AmmoCount

var clip = 3: set = set_clip
var max_clip = 4: set = set_max_clip

func set_clip(value):
	clip = clamp(value, 0, max_clip)
	Clip.size.x = clip * HEARTWIDTH

func set_max_clip(value):
	max_clip = max(value, 1)
	self.clip = min(clip, max_clip)

func set_ammo_count(value: int):
	AmmoCount.text = String.num(value) + "x"

func _ready():
	# initialise clip
	self.max_clip = PlayerStats.max_clip
	self.clip = PlayerStats.clip
	
	# connect singals
# warning-ignore:return_value_discarded
	PlayerStats.connect("clip_changed", Callable(self, "set_clip"))
# warning-ignore:return_value_discarded
	PlayerStats.connect("max_clip_changed", Callable(self, "set_max_clip"))
# warning-ignore:return_value_discarded
	PlayerStats.connect("ammo_count_changed", Callable(self, "set_ammo_count"))
