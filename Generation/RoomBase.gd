extends Node2D

@onready var EnemiesActive: Node = $EnemiesActive
@onready var FlowerTileMap: TileMap = $FlowerTileMap
@onready var WallTileMap: TileMap = $WallTileMap

var BoxPileScene = preload("res://Generation/Obstacles/BoxPile.tscn")
var ShrubScene = preload("res://Generation/Obstacles/Shrub.tscn")

var MeleeEnemyScene = preload("res://Enemy/MeleeEnemy.tscn")
var SingleShotEnemyScene = preload("res://Enemy/SingleShotEnemy.tscn")
var BurstShotEnemyScene = preload("res://Enemy/BurstShotEnemy.tscn")

enum {
	SINGLESHOT,
	BURSTSHOT,
	MELEE
}
var enemy_types = 3

signal first_entered(location)

@export var MAP_LOCATION: Vector2
@export var ROOM_CENTRE = Vector2(320, 320)
@export var SPAWN_SPREAD = 200
@export var FLOWER_TILE_COUNT = 40
@export var TILES_TO_CENTRE = 10
@export var TILE_SPREAD = 10

@export var MAX_SHRUB_COUNT = 8
@export var MAX_BOX_COUNT = 6
@export var ENTITY_SPAWN_ROTATION = 2 * PI
@export var MAX_SPAWN_ATTEMPTS = 3


var spawnEnemies = true
var visited = false

func generate_objects():
	# walls and obstacles
	generate_walls(randi() % 100)
	generate_flowers()
	generate_obstacles()
	
	# generate enemies and items
	if spawnEnemies:
		generate_enemies()

func create_given_tiles(topLeft: Vector2, bottomRight: Vector2, tileMap: TileMap):
	for x in range (bottomRight.x - topLeft.x + 1):
		for y in range (bottomRight.y - topLeft.y + 1):
			tileMap.set_cell(0, Vector2i(int(topLeft.x + x), int(topLeft.y + y)))

func generate_walls(wall_rand: int):
	if(wall_rand < 15):
		create_given_tiles(Vector2(-2,8), Vector2(1,11), WallTileMap)
	elif(wall_rand < 30):
		create_given_tiles(Vector2(8,-2), Vector2(11,1), WallTileMap)
	elif(wall_rand < 45):
		create_given_tiles(Vector2(18,8), Vector2(21,11), WallTileMap)
	elif(wall_rand < 60):
		create_given_tiles(Vector2(8,18), Vector2(11,21), WallTileMap)

func generate_obstacles():
	# crates
	for _i in range(randi() % MAX_BOX_COUNT):
		instance_room_object(BoxPileScene, randf() * ENTITY_SPAWN_ROTATION)
	
	#shrubs
	for _i in range(randi() % MAX_SHRUB_COUNT):
		instance_room_object(ShrubScene, randf() * ENTITY_SPAWN_ROTATION)

func generate_flowers():
	for _i in range(FLOWER_TILE_COUNT):
		FlowerTileMap.set_cell(
			0, 
			Vector2i(TILES_TO_CENTRE + randi_range(-TILE_SPREAD,TILE_SPREAD), TILES_TO_CENTRE + randi_range(-TILE_SPREAD,TILE_SPREAD)), 
			-1, 
			Vector2i(-1,-1), 
			# get_subtile_without_priority(0, FlowerTileMap)
			0
		)

# ---------------- might have broken this one woops ----------------------
func get_subtile_without_priority(tilemap: TileMap):
	var tiles := tilemap.tile_set
	var rect := tiles.tile_size
	var rand_x = randi() % rect.x
	var rand_y = randi() % rect.y
	return Vector2(rand_x, rand_y)

func generate_enemies(maxEnemies: int = 3):
	var no_enemies = randi() % maxEnemies
	
	for _e in range(no_enemies):
		instance_kinematic(get_random_enemy_type())

func get_random_enemy_type():
	match randi() % enemy_types:
		SINGLESHOT:
			return SingleShotEnemyScene
		BURSTSHOT:
			return BurstShotEnemyScene
		MELEE:
			return MeleeEnemyScene

func instance_kinematic(scene):
	var entity: CharacterBody2D = scene.instantiate()
	spawn_entity(entity, entity.shape_owner_get_shape(0,0), "EnemiesActive") # will need to add a more general spawn node

func instance_room_object(scene, spawnRotation: int):
	var entity: CollisionObject2D = scene.instantiate()
	entity.rotate(spawnRotation)
	spawn_entity(entity, entity.find_child("SpawnCollision").shape_owner_get_shape(0,0), "EnemiesActive") # will need to add a more general spawn node

func spawn_entity(instance: Node2D, shape: Shape2D, spawnNode: String, attempt: int = 0):
	# generate spawn location
	var random_position = global_position + Vector2(320, 320) + Vector2(randf_range(-SPAWN_SPREAD, SPAWN_SPREAD), randf_range(-SPAWN_SPREAD, SPAWN_SPREAD))
	instance.global_position = random_position
	
	# query spawn location
	var query = PhysicsShapeQueryParameters2D.new()
	query.set_transform(instance.global_transform)
	query.set_shape(shape)
	
	var space_state = get_world_2d().get_direct_space_state()
	var result = space_state.get_rest_info(query) 
	
	# if query result exists than spawn is unsafe
	if not result || attempt > MAX_SPAWN_ATTEMPTS:
		get_node(spawnNode).add_child(instance)
	else:
		spawn_entity(instance, shape, spawnNode, attempt + 1)

func migrate_enemy(enemy):
	enemy.get_parent().remove_child(enemy)
	EnemiesActive.add_child(enemy)

func _on_RoomArea_body_entered(_body):
	if not visited:
		emit_signal("first_entered", MAP_LOCATION)
		visited = true

func _on_EnemyDetectionArea_body_entered(body: CharacterBody2D):
	if not EnemiesActive.is_ancestor_of(body):
		call_deferred("migrate_enemy", body)
