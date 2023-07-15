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
		spawn_enemy(room_inst)

func spawn_enemy(room_inst):
	# create instance
	var enemy: KinematicBody2D = get_random_enemy_type().instance()
	
	# check spawn is good
	var spawn_is_unsafe = true
	while spawn_is_unsafe:
		# generate spawn location
		var random_position = room_inst.global_position + Vector2(320, 320) + Vector2(rand_range(-240, 240), rand_range(-240, 240))
		enemy.global_position = random_position
		
		# query spawn location
		var query = Physics2DShapeQueryParameters.new()
		query.set_transform(enemy.global_transform)
		query.set_shape(enemy.shape_owner_get_shape(0,0))
		
		var space_state = get_world_2d().get_direct_space_state()
		var result = space_state.get_rest_info(query) 
		
		# if query result exists than spawn is unsafe
		if not result:
			spawn_is_unsafe = false
		
	room_inst.get_node("EnemiesActive").add_child(enemy)
	return enemy

func instanstiate_enemy(room_inst, spawn_position, enemy_scene):
	# create instance
	var enemy: KinematicBody2D = enemy_scene.instance()
	enemy.global_position = spawn_position
	room_inst.get_node("EnemiesActive").add_child(enemy)
	return enemy

func get_random_enemy_type():
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
	
