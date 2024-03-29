extends Node2D

@onready var EnemiesActive: Node = $EnemiesActive
@onready var FlowerTileMap: TileMap = $FlowerTileMap
@onready var WallTileMap: TileMap = $WallTileMap

var BoxPileScene = preload("res://Generation/Obstacles/BoxPile.tscn")
var ShrubScene = preload("res://Generation/Obstacles/Shrub.tscn")
var EndScene = preload("res://Generation/Interactables/Goal.tscn")

var MeleeEnemyScene = preload("res://Enemy/MeleeEnemy.tscn")
var SingleShotEnemyScene = preload("res://Enemy/SingleShotEnemy.tscn")
var BurstShotEnemyScene = preload("res://Enemy/BurstShotEnemy.tscn")

const BLOCK_WALL: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]

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
@export var WALL_CHANCE_STEP = 30

@export var MIN_END_SPAWN = 4
@export var MAX_END_SPAWN_RATE = 20
@export var SPAWN_END = 100

@export var MAX_SHRUB_COUNT = 8
@export var MAX_BOX_COUNT = 6
@export var ENTITY_SPAWN_ROTATION = 2 * PI
@export var MAX_SPAWN_ATTEMPTS = 3


var spawnEnemies = true
var spawnObjects = true
var visited = false

func generate_objects():
	if (MAP_LOCATION.length() - MIN_END_SPAWN) * (randi() % MAX_END_SPAWN_RATE) >= SPAWN_END:
		# generate pretty flowers
		generate_flowers()
		
		# generate the end
		var endInstance = EndScene.instantiate()
		spawn_entity(endInstance, null, "Objects", false)
	else:
		# walls and obstacles
		if spawnObjects:
			generate_walls(randi() % 100)
			generate_flowers()
			generate_obstacles()
		
		# generate enemies and items
		if spawnEnemies:
			generate_enemies()

func create_given_tiles(position: Vector2i, tileMap: TileMap, pattern: TileMapPattern):
	tileMap.set_pattern(1, position, pattern)

func generate_walls(wall_rand: int):
	if(wall_rand < WALL_CHANCE_STEP):
		create_given_tiles(Vector2(-2,8), WallTileMap, WallTileMap.get_pattern(0, BLOCK_WALL))
		create_given_tiles(Vector2(0,8), WallTileMap, WallTileMap.get_pattern(0, BLOCK_WALL))
	elif(wall_rand < WALL_CHANCE_STEP * 2):
		create_given_tiles(Vector2(8,-2), WallTileMap, WallTileMap.get_pattern(0, BLOCK_WALL))
		create_given_tiles(Vector2(10,-2), WallTileMap, WallTileMap.get_pattern(0, BLOCK_WALL))
	elif(wall_rand < WALL_CHANCE_STEP * 3):
		create_given_tiles(Vector2(18,8), WallTileMap, WallTileMap.get_pattern(0, BLOCK_WALL))
		create_given_tiles(Vector2(20,8), WallTileMap, WallTileMap.get_pattern(0, BLOCK_WALL))
	elif(wall_rand < WALL_CHANCE_STEP * 4):
		create_given_tiles(Vector2(8,18), WallTileMap, WallTileMap.get_pattern(0, BLOCK_WALL))
		create_given_tiles(Vector2(10,18), WallTileMap, WallTileMap.get_pattern(0, BLOCK_WALL))

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
	spawn_entity(entity, entity.find_child("SpawnCollision").shape_owner_get_shape(0,0), "Objects") # will need to add a more general spawn node

func spawn_entity(instance: Node2D, shape: Shape2D, spawnNode: String, collision: bool = true, attempt: int = 0):
	# generate spawn location
	var random_position = global_position + Vector2(320, 320) + Vector2(randf_range(-SPAWN_SPREAD, SPAWN_SPREAD), randf_range(-SPAWN_SPREAD, SPAWN_SPREAD))
	instance.global_position = random_position
	
	if collision: 
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
			spawn_entity(instance, shape, spawnNode, collision, attempt + 1)
	else:
		get_node(spawnNode).add_child(instance)

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
