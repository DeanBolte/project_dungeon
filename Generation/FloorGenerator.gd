extends Node2D



export var ROOM_DISTANCE = 640

onready var RoomsActive = $RoomsActive
onready var EnemiesActive = $EnemiesActive
onready var NavMesh = $ActiveNavMesh
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
	PlayerContainer.add_child(playerInst)
	
	playerInst.global_position = Vector2(x, y)
	
	return playerInst

# creates a 
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
		
		# populate room
		populate_enemies(roomInst)
		
		# add the rooms nav mesh to the active nav mesh
		var navMeshInst = roomInst.get_node("NavigationPolygonInstance")
		roomInst.remove_child(navMeshInst)
		NavMesh.add_child(navMeshInst)
		navMeshInst.global_position = roomInst.global_position
		
		# connect generation trigger
		roomInst.connect("first_entered", self, "generate_next")
		# add room to map
		roomMap[key] = roomInst

		return roomInst

func populate_enemies(roomInst):
	var no_enemies = randi() % 3
	
	for e in range(no_enemies):
		var enemy = get_random_enemy()
		EnemiesActive.add_child(enemy)
		enemy.initialise_nav(NavMesh)
		
		var random_position = Vector2(rand_range(-240, 240), rand_range(-240, 240))
		enemy.global_position = roomInst.global_position + Vector2(320, 320) + random_position

func get_random_enemy():
	match randi() % enemy_types:
		SINGLESHOT:
			return SingleShotEnemyScene.instance()
		BURSTSHOT:
			return BurstShotEnemyScene.instance()
		MELEE:
			return MeleeEnemyScene.instance()

# generate all adjacent rooms
func generate_next(location):
	call_deferred("create_room", location.x+1, location.y)
	call_deferred("create_room", location.x-1, location.y)
	call_deferred("create_room", location.x, location.y+1)
	call_deferred("create_room", location.x, location.y-1)
