extends Area2D

const PUNCH_VELOCITY_MULTIPLIER = 2

func _on_PunchBox_area_entered(area):
	# this is pretty shoddy
	area.get_parent().take_hit(2, $"..".aimingNormalVector * PUNCH_VELOCITY_MULTIPLIER)
