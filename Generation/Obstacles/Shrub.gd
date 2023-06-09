extends StaticBody2D

var broken = false

func _on_Area2D_area_entered(area):
	if (!broken):
		$AnimationPlayer.play("destruction")
		broken = true
