extends VBoxContainer

onready var Menu = get_parent()
onready var Options = $MenuItems/Options

enum {
	CONTINUE,
	PLAY,
	OPTIONS,
	EXIT
}
var selection setget set_selection
var max_options = 3

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	update()

func _physics_process(_delta):
	# Player inputs
	if Input.is_action_just_pressed("ui_accept"):
		select()
	
	if Input.is_action_just_pressed("ui_down"):
		move_selection(1)
	if Input.is_action_just_pressed("ui_up"):
		move_selection(-1)

func move_selection(value: int):
	self.selection += value
	if selection > max_options:
		self.selection = 0
	elif selection < 0:
		self.selection = max_options

func set_selection(value: int):
	selection = value
	update()

func select():
	match selection:
		CONTINUE:
			Saveload.continue_save()
		PLAY:
			Saveload.init_game()
		OPTIONS:
			Menu.set_active_menu(Menu.OPTIONS)
		EXIT:
			get_tree().quit()

func update():
	for o in Options.get_children():
		o.margin_left = 0
	match selection:
		CONTINUE:
			Options.get_node("Continue").margin_left = 20
		PLAY:
			Options.get_node("Play").margin_left = 20
		OPTIONS:
			Options.get_node("Options").margin_left = 20
		EXIT:
			Options.get_node("Exit").margin_left = 20

func _on_Continue_mouse_entered():
	self.selection = CONTINUE

func _on_Play_mouse_entered():
	self.selection = PLAY

func _on_Options_mouse_entered():
	self.selection = OPTIONS

func _on_Exit_mouse_entered():
	self.selection = EXIT
