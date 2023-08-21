extends StaticBody2D

@onready var ShrubCollision = $CollisionShape2D

var broken = false

func breakShrub():
	$AnimationPlayer.play("destruction")
	ShrubCollision.set_deferred("disabled", true)
	broken = true

func _on_Area2D_area_entered(_area):
	if (!broken): breakShrub()

func _on_Area2D_body_entered(_body: Node) -> void:
	if (!broken): breakShrub()
