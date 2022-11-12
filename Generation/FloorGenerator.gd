extends Node2D

export var ROOM_DISTANCE = 640

onready var RoomsActive = $RoomsActive

var BaseRoomScene = preload("res://Generation/RoomBase.tscn")
var PlayerScene = preload("res://Player/Player.tscn")

var RoomMap

func _ready():
	create_room(0, 0)
	spawn_player(0, 0)
	
	
	

func spawn_player(x, y):
	var playerInst = PlayerScene.instance()
	add_child(playerInst)
	
	playerInst.global_position = Vector2(x, y)

func create_room(x, y):
	var roomInst = BaseRoomScene.instance()
	RoomsActive.add_child(roomInst)
	
	roomInst.global_position = Vector2(x, y)
