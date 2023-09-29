extends VBoxContainer

@onready var Menu = get_parent()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Menu.set_active_menu(Menu.MAINMENU)
