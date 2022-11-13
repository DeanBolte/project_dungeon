extends Node2D



export var ROOM_DISTANCE = 640

onready var RoomsActive = $RoomsActive

var BaseRoomScene = preload("res://Generation/RoomBase.tscn")
var PlayerScene = preload("res://Player/Player.tscn")

var roomMap = Dictionary()
var Player

func _ready():
	var startingRoom = create_room(0, 0)
	Player = spawn_player(320, 320)

func spawn_player(x, y):
	var playerInst = PlayerScene.instance()
	add_child(playerInst)
	
	playerInst.global_position = Vector2(x, y)
	
	return playerInst

func create_room(x, y):
	var keyString = "({x}, {y})"
	var key = keyString.format({"x": x, "y": y})
	if(not roomMap.has(key)):
		var roomInst = BaseRoomScene.instance()
		RoomsActive.add_child(roomInst)

		roomInst.global_position = Vector2(x*ROOM_DISTANCE, y*ROOM_DISTANCE)
		roomInst.MAP_LOCATION = Vector2(x, y)

		roomInst.connect("first_entered", self, "generate_next")
		roomMap[key] = roomInst

		return roomInst

#func generate_next(location):
#	create_room(location.x+1, location.y)
#	yield(get_tree(), "physics_frame")
#	create_room(location.x-1, location.y)
#	yield(get_tree(), "physics_frame")
#	create_room(location.x, location.y+1)
#	yield(get_tree(), "physics_frame")
#	create_room(location.x, location.y-1)

func generate_next(location):
	call_deferred("create_room", location.x+1, location.y)
	call_deferred("create_room", location.x-1, location.y)
	call_deferred("create_room", location.x, location.y+1)
	call_deferred("create_room", location.x, location.y-1)
