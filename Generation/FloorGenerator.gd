extends Node2D



export var ROOM_DISTANCE = 640

onready var RoomsActive = $RoomsActive

var BaseRoomScene = preload("res://Generation/RoomBase.tscn")
var PlayerScene = preload("res://Player/Player.tscn")

var roomMap = Dictionary()
var Player

# initialise first room and player
func _ready():
	randomize()
	var startingRoom = create_room(0, 0)
	Player = spawn_player(320, 320)

# instantiate packed player scene and add to heirarchy
func spawn_player(x, y):
	var playerInst = PlayerScene.instance()
	add_child(playerInst)
	
	playerInst.global_position = Vector2(x, y)
	
	return playerInst

func create_room(x, y):
	var keyString = "({x}, {y})"
	var key = keyString.format({"x": x, "y": y})
	if(not roomMap.has(key)):
		# instantiate packed room scene
		var roomInst = BaseRoomScene.instance()
		RoomsActive.add_child(roomInst)
		
		# set room location
		roomInst.global_position = Vector2(x*ROOM_DISTANCE, y*ROOM_DISTANCE)
		roomInst.MAP_LOCATION = Vector2(x, y)
		
		# connect generation trigger
		roomInst.connect("first_entered", self, "generate_next")
		# add room to map
		roomMap[key] = roomInst

		return roomInst


# generate all adjacent rooms
func generate_next(location):
	call_deferred("create_room", location.x+1, location.y)
	call_deferred("create_room", location.x-1, location.y)
	call_deferred("create_room", location.x, location.y+1)
	call_deferred("create_room", location.x, location.y-1)
