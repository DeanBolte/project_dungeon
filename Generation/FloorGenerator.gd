extends Node2D

onready var RoomsActive = $RoomsActive

var BaseRoomScene = preload("res://Generation/RoomBase.tscn")
var PlayerScene = preload("res://Player/Player.tscn")

func _ready():
	var roomInst = BaseRoomScene.instance()
	RoomsActive.add_child(roomInst)
	
	var playerInst = PlayerScene.instance()
	add_child(playerInst)
