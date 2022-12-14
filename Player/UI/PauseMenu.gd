extends Control

var is_paused: bool = false setget set_is_paused

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_pause"):
		self.is_paused = !is_paused

func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused

func _on_ResumeButton_pressed():
	self.is_paused = false

func _on_QuitButton_pressed():
	get_tree().quit()
