extends Node2D

onready var EnemiesActive: Node = $EnemiesActive
onready var FlowerTileMap: TileMap = $FlowerTileMap

var BoxPileScene = preload("res://Generation/Obstacles/BoxPile.tscn")

signal first_entered(location)

export (Vector2) var MAP_LOCATION
export var ROOM_CENTRE = Vector2(320, 320)
export var OBSTACLE_SPREAD = 200
export var FLOWER_TILE_COUNT = 40
export var TILES_TO_CENTRE = 10
export var TILE_SPREAD = 10

var visited = false

func generate_objects():
	generate_flowers()
	generate_obstacles()

func generate_obstacles():
	for i in range(randi() % 4):
		var boxpileinst = BoxPileScene.instance()
		add_child(boxpileinst)
		boxpileinst.global_position = global_position + ROOM_CENTRE + Vector2(rand_range(-OBSTACLE_SPREAD, OBSTACLE_SPREAD), rand_range(-OBSTACLE_SPREAD, OBSTACLE_SPREAD))

func generate_flowers():
	for i in range(FLOWER_TILE_COUNT):
		FlowerTileMap.set_cell(
			TILES_TO_CENTRE + rand_range(-TILE_SPREAD,TILE_SPREAD), 
			TILES_TO_CENTRE + rand_range(-TILE_SPREAD,TILE_SPREAD), 
			0, 
			false, 
			false, 
			false, 
			get_subtile_without_priority(0, FlowerTileMap)
		)

func get_subtile_without_priority(id, tilemap: TileMap):
	var tiles = tilemap.tile_set
	var rect = tilemap.tile_set.tile_get_region(id)
	var size_x: int = rect.size.x / tiles.autotile_get_size(id).x
	var size_y: int = rect.size.y / tiles.autotile_get_size(id).y
	var rand_x = randi() % size_x 
	var rand_y = randi() % size_y
	return Vector2(rand_x, rand_y)

func migrate_enemy(enemy):
	enemy.get_parent().remove_child(enemy)
	EnemiesActive.add_child(enemy)

func _on_RoomArea_body_entered(_body):
	if not visited:
		emit_signal("first_entered", MAP_LOCATION)
		visited = true

func _on_EnemyDetectionArea_body_entered(body: KinematicBody2D):
	if not EnemiesActive.is_a_parent_of(body):
		call_deferred("migrate_enemy", body)
