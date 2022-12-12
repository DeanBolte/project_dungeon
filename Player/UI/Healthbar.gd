extends Control

const HEARTWIDTH = 8

onready var HealthBackground = $HealthBackground
onready var HealthForeground = $HealthForeground

var hearts = 3 setget set_hearts
var max_hearts = 4 setget set_max_hearts

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	HealthForeground.rect_size.x = hearts * HEARTWIDTH

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)

func _ready():
	# initialise health
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	
	# initialise background
	HealthBackground.rect_size.x = self.max_hearts * HEARTWIDTH
	
	# connect singals
# warning-ignore:return_value_discarded
	PlayerStats.connect("health_changed", self, "set_hearts")
# warning-ignore:return_value_discarded
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
