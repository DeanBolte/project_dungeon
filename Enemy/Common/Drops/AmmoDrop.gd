extends "res://Enemy/Common/Drops/Drop.gd"

@export var AMMO_TYPE = PlayerStats.AmmoType.STANDARD

func _on_PlayerDetectionArea_body_entered(body):
	Player = body

func _on_PlayerDetectionArea_body_exited(_body):
	Player = null

func _on_PlayerPickUp_body_entered(_body):
	PlayerStats.increment_ammo_count(AMMO_TYPE, 1)
	queue_free()
