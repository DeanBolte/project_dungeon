extends "res://Enemy/Common/Drops/Drop.gd"

func _on_PlayerDetectionArea_body_entered(body):
	Player = body

func _on_PlayerDetectionArea_body_exited(_body):
	Player = null

func _on_PlayerPickUpArea_body_entered(_body):
	PlayerStats.increment_health()
	queue_free()
