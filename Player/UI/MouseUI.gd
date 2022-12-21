extends Control

onready var animations := $AnimationPlayer

func _ready():
# warning-ignore:return_value_discarded
	PlayerStats.connect("reloading", self, "reload_animation")

func _process(delta):
	rect_position = get_global_mouse_position()

func reload_animation(value):
	animations.play("Reload")
