extends Control

onready var FPSCounter := $DebugList/FPS/FPSCounter

func _process(_delta):
	# reveal fps
	FPSCounter.text = String(Engine.get_frames_per_second())
