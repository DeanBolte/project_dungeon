extends Control

onready var Options = $MarginContainer/VerticalSeperator/Menu/Options

enum {
	PLAY,
	OPTIONS,
	EXIT
}
var selection = PLAY
var max_options = 3

func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		select()
	
	if Input.is_action_just_pressed("ui_down"):
		move_selection(1)
	if Input.is_action_just_pressed("ui_up"):
		move_selection(-1)
	
	update()

func move_selection(value):
	selection += value
	if selection > max_options - 1:
		selection = 0
	elif selection < 0:
		selection = max_options - 1

func select():
	match selection:
		PLAY:
			PlayerStats.initialise()
			get_tree().change_scene("res://Scenes/dungeon_scene.tscn")
		OPTIONS:
			print("placeholder option, TODO")
		EXIT:
			get_tree().quit()

func update():
	for o in Options.get_children():
		o.margin_left = 0
	match selection:
		PLAY:
			Options.get_node("Play").margin_left = 20
		OPTIONS:
			Options.get_node("Options").margin_left = 20
		EXIT:
			Options.get_node("Exit").margin_left = 20
