extends Control

const SPRITE_WIDTH = 32

@onready var Clip = $Clip
@onready var AmmoCount = $AmmoCount

func _process(delta):
	Clip.size.x = PlayerStats.clip * SPRITE_WIDTH
	AmmoCount.text = String.num(PlayerStats.get_ammo_count()) + "x"
