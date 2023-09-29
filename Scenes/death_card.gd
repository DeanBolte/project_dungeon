extends Control

@onready var SubtextLabel: Label = $VBoxContainer/Subtext

var MainMenuScene = "res://MainMenu/Menu.tscn"

@export var ACTION_DELAY_SECONDS = 1

var actionDelay = ACTION_DELAY_SECONDS

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	SubtextLabel.visible = false

func _process(delta: float) -> void:
	if actionDelay > 0:
		actionDelay -= delta
	else:
		SubtextLabel.visible = true

func _input(event: InputEvent) -> void:
	if actionDelay <= 0:
		if not event is InputEventMouseMotion:
			get_tree().change_scene_to_file(MainMenuScene)
