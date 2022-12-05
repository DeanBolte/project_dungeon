extends Node2D

signal first_entered(location)

export (Vector2) var MAP_LOCATION

var visited = false

func _on_RoomArea_body_entered(_body):
	if not visited:
		emit_signal("first_entered", MAP_LOCATION)
		visited = true

