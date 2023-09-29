extends Node2D

var EndCard = "res://Scenes/end_card.tscn"

@onready var Animations = $AnimationPlayer

func _ready():
	Animations.play("oscilate")

func _process(delta):
	rotate(PI * delta)

func _on_player_detection_body_entered(_body):
	get_tree().change_scene_to_file(EndCard)
