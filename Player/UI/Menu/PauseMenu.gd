extends Control

var is_paused: bool = false: set = set_is_paused

func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_pause"):
		self.is_paused = !is_paused

func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused
	
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _on_ResumeButton_pressed():
	self.is_paused = false

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_SaveButton_pressed():
	Saveload.save_data()

func _on_MenuButton_pressed():
	self.is_paused = false
# warning-ignore:return_value_discarded
	get_tree().change_scene_to_file("res://MainMenu/Menu.tscn")
