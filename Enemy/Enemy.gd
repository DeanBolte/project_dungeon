extends KinematicBody2D

export var ACCELERATION = 2

var velocity = Vector2.ZERO

onready var Player = get_tree().root.get_child(0).get_node("Player")

func _physics_process(delta):
	velocity = (Player.global_position - global_position) * ACCELERATION
	
	velocity = move_and_slide(velocity)


func _on_HurtBox_body_entered(body):
	queue_free()
