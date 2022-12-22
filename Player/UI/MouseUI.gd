extends Control

onready var animations := $AnimationPlayer

func _ready():
# warning-ignore:return_value_discarded
	PlayerStats.connect("reloading", self, "reload_animation")

func _process(_delta):
	rect_position = get_global_mouse_position()

func reload_animation(duration):
	if not animations.is_playing():
		animations.play("Reload", 0.0, 1/duration)
	else:
		animations.advance(duration)

func reload_animation_over():
	animations.stop(true)
