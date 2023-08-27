extends Control

const HEARTWIDTH = 8

@onready var HealthBackground: TextureRect = $HealthBackground
@onready var HealthForeground: TextureRect = $HealthForeground

var hearts = 3: set = set_hearts
var max_hearts = 4: set = set_max_hearts

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	HealthForeground.size.x = hearts * HEARTWIDTH

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)

func _ready():
	# initialise health
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	
	# initialise background
	HealthBackground.size.x = self.max_hearts * HEARTWIDTH
	
	# connect singals
# warning-ignore:return_value_discarded
	PlayerStats.health_changed.connect(set_hearts)
# warning-ignore:return_value_discarded
	PlayerStats.max_health_changed.connect(set_max_hearts)
