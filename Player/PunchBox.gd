extends Area2D

func _on_PunchBox_area_entered(area):
	# this is pretty shoddy
	area.get_parent().take_hit(2, $"..".aimingNormalVector * 2)
