extends Control

var MainMenuScene = "res://MainMenu/Menu.tscn"

export var ACTION_DELAY_SECONDS = 1

var actionDelay = ACTION_DELAY_SECONDS

func _process(delta: float) -> void:
	if actionDelay > 0:
		actionDelay -= delta

func _input(event: InputEvent) -> void:
	if actionDelay <= 0:
		if not event is InputEventMouseMotion:
			get_tree().change_scene(MainMenuScene)
