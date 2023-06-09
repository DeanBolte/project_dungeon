extends Node2D

export var ROOM_DISTANCE = 640
export var ROOM_LOAD_DISTANCE = 2400

onready var RoomsActive = $RoomsActive
onready var PlayerContainer = $PlayerActive

var BaseRoomScene = preload("res://Generation/RoomBase.tscn")
var PlayerScene = preload("res://Player/Player.tscn")
var MeleeEnemyScene = preload("res://Enemy/MeleeEnemy.tscn")
var SingleShotEnemyScene = preload("res://Enemy/SingleShotEnemy.tscn")
var BurstShotEnemyScene = preload("res://Enemy/BurstShotEnemy.tscn")

enum {
	SINGLESHOT,
	BURSTSHOT,
	MELEE
}
var enemy_types = 3

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
		room_inst.generate_objects()
		
		if enemies:
			populate_enemies(room_inst)
		
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

func populate_enemies(room_inst: Node2D, enemy_count: int = 3):
	var no_enemies = randi() % enemy_count
	
	for _e in range(no_enemies):
		var enemy_type = get_random_enemy()
		var random_position = room_inst.global_position + Vector2(320, 320) + Vector2(rand_range(-240, 240), rand_range(-240, 240))
		instanstiate_enemy(room_inst, random_position, enemy_type)

func instanstiate_enemy(room_inst, position: Vector2, enemy_scene):
	var enemy = enemy_scene.instance()
	room_inst.get_node("EnemiesActive").add_child(enemy)
	enemy.global_position = position
	return enemy

func get_random_enemy():
	match randi() % enemy_types:
		SINGLESHOT:
			return SingleShotEnemyScene
		BURSTSHOT:
			return BurstShotEnemyScene
		MELEE:
			return MeleeEnemyScene

func enemy_scene_to_enum(enemy_scene):
	match enemy_scene:
		MeleeEnemyScene:
			return MELEE
		SingleShotEnemyScene:
			return SINGLESHOT
		BurstShotEnemyScene:
			return BURSTSHOT

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
	
