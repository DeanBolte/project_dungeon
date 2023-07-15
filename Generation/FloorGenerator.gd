extends Node2D

export var ROOM_DISTANCE = 640
export var ROOM_LOAD_DISTANCE = 2400

onready var RoomsActive = $RoomsActive
onready var PlayerContainer = $PlayerActive

var BaseRoomScene = preload("res://Generation/RoomBase.tscn")
var PlayerScene = preload("res://Player/Player.tscn")

var roomMap := Dictionary()
var Player

# initialise first room and player
func _ready():
	randomize()
	create_room(0, 0, false)
	Player = spawn_player(320, 320)

func _process(_delta):
	for room in roomMap.keys():
		if is_a_parent_of(roomMap[room]):
			if Player.global_position.distance_to(room * ROOM_DISTANCE) > ROOM_LOAD_DISTANCE:
				RoomsActive.call_deferred("remove_child", roomMap[room])
		else:
			if Player.global_position.distance_to(room * ROOM_DISTANCE) <= ROOM_LOAD_DISTANCE:
				RoomsActive.call_deferred("add_child", roomMap[room])

# instantiate packed player scene and add to heirarchy
func spawn_player(x, y):
	var playerInst = PlayerScene.instance()
	PlayerContainer.add_child(playerInst)
	
	playerInst.global_position = Vector2(x, y)
	
	return playerInst

# room creation
func create_room(x: float, y: float, enemies: bool):
	var key = Vector2(x, y)
	var room_inst = instantiate_room_inst(key)
	
	if room_inst:
		# cosntruct room state
		room_inst.spawnEnemies = enemies
		
		# procedural calls
		room_inst.generate_objects()
		
		# add room to map
		roomMap[key] = room_inst
		
		return room_inst

func instantiate_room_inst(key: Vector2):
	if(not roomMap.has(key)):
		# instantiate packed room scene
		var roomInst = BaseRoomScene.instance()
		RoomsActive.add_child(roomInst)
		
		# set room location
		roomInst.global_position = Vector2(key.x*ROOM_DISTANCE, key.y*ROOM_DISTANCE)
		roomInst.MAP_LOCATION = key
		
		# connect generation trigger
		roomInst.connect("first_entered", self, "generate_next")
		
		return roomInst

func flush_room_map():
	roomMap = Dictionary()

func instanstiate_entity(room_inst, spawn_position, entity_scene):
	# create instance
	var entity: KinematicBody2D = entity_scene.instance()
	entity.global_position = spawn_position
	room_inst.get_node("EnemiesActive").add_child(entity)
	return entity

#func enemy_scene_to_enum(enemy_scene):
	#match enemy_scene:
	#	MeleeEnemyScene:
	#		return MELEE
	#	SingleShotEnemyScene:
	#		return SINGLESHOT
	#	BurstShotEnemyScene:
	#		return BURSTSHOT

# generate all adjacent rooms
func generate_next(location):
	call_deferred("create_room", location.x+1, location.y, true)
	call_deferred("create_room", location.x-1, location.y, true)
	call_deferred("create_room", location.x, location.y+1, true)
	call_deferred("create_room", location.x, location.y-1, true)
	call_deferred("create_room", location.x+1, location.y+1, true)
	call_deferred("create_room", location.x+1, location.y-1, true)
	call_deferred("create_room", location.x-1, location.y+1, true)
	call_deferred("create_room", location.x-1, location.y-1, true)
	
