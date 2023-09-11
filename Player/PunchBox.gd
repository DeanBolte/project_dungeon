extends Area2D

const PUNCH_VELOCITY_MULTIPLIER = 2

func _on_PunchBox_area_entered(area):
	if area.get_parent().has_method('take_hit'):
		area.get_parent().take_hit(2, get_parent().aimingNormalVector * PUNCH_VELOCITY_MULTIPLIER)
