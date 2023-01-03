extends Control

onready var TitleMenu = $TitleMenu
onready var OptionMenu = $OptionMenu

enum {
	MAINMENU,
	OPTIONS
}
var active_menu: int = MAINMENU setget set_active_menu

func _ready():
	remove_child(TitleMenu)
	remove_child(OptionMenu)
	set_active_menu(active_menu)

func set_active_menu(menu_enum: int):
	# disable current active menu
	var active = menu_id_to_inst(active_menu)
	if is_a_parent_of(active):
		remove_child(active)
	
	# activate new menu
	active_menu = menu_enum
	active = menu_id_to_inst(active_menu)
	add_child(active)

func menu_id_to_inst(menu_index: int):
	var menuInst
	match menu_index:
		MAINMENU:
			menuInst = TitleMenu
		OPTIONS:
			menuInst = OptionMenu
	return menuInst

func _on_ExitOptions_pressed():
	self.active_menu = MAINMENU
