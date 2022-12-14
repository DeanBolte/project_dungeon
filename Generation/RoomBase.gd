extends Node2D

onready var EnemiesActive: Node = $EnemiesActive

signal first_entered(location)

export (Vector2) var MAP_LOCATION

var visited = false

func _on_RoomArea_body_entered(_body):
	if not visited:
		emit_signal("first_entered", MAP_LOCATION)
		visited = true

func _on_EnemyDetectionArea_body_entered(body: KinematicBody2D):
	if not EnemiesActive.is_a_parent_of(body):
		body.get_parent().remove_child(body)
		EnemiesActive.add_child(body)
