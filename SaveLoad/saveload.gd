extends Node

const SAVE_FILE_PATH = "user://save_file.save"
var game_data = {}

var packed_baseroom = load("res://Generation/RoomBase.tscn")

func _ready():
	pass

func save_data():
# warning-ignore:return_value_discarded
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	
	# save player details
	file.store_var(save_player_stats())
	file.store_var(save_player_position())
	file.store_var(save_world())
	
	file.close()

func save_player_stats():
	var player_stats = {
		"max_health" : PlayerStats.max_health,
		"health" : PlayerStats.health,
		"max_clip" : PlayerStats.max_clip,
		"clip" : PlayerStats.clip,
		"selected_shot_type" : PlayerStats.selected_shot_type,
		"shot_types" : PlayerStats.shot_types,
		"ammo_counts" : PlayerStats.ammo_counts
	}
	return player_stats

func save_player_position():
	var player = get_tree().root.find_child("Player", true, false)
	var player_position = {
		"x" : player.global_position.x,
		"y" : player.global_position.y
	}
	return player_position

func save_world():
	var world_data = {
		"room_map" : save_room_map()
	}
	return world_data

func save_room_map():
	var floor_generator = get_tree().root.find_child("FloorGenerator", true, false)
	var room_map := Dictionary()
	for room in floor_generator.roomMap:
		room_map[room] = save_room(floor_generator.roomMap[room])
	return room_map

func save_room(room_inst):
	var room = {
		"x" : room_inst.MAP_LOCATION.x,
		"y" : room_inst.MAP_LOCATION.y,
		"visited" : room_inst.visited,
		"enemies" : save_enemies(room_inst)
	}
	return room

func save_enemies(room_inst: Node2D):
	var enemies_active := room_inst.find_child("EnemiesActive").get_children()
	var enemies = Dictionary()
	for e in enemies_active:
		if e.has_method("set_health"):
			enemies[e.get_index()] = {
				"enemy_type" : e.get_scene_file_path(),
				"position" : e.global_position,
				"health" : e.health
			}
	return enemies

func load_data():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return # no save file to load
	
# warning-ignore:return_value_discarded
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	
	# load player data
	load_player_stats(file.get_var())
	load_player_position(file.get_var())
	load_world(file.get_var())
	
	file.close()

func load_player_stats(player_stats):
	PlayerStats.max_health = player_stats.max_health
	PlayerStats.health = player_stats.health
	PlayerStats.max_clip = player_stats.max_clip
	PlayerStats.clip = player_stats.clip
	PlayerStats.selected_shot_type = player_stats.selected_shot_type
	PlayerStats.shot_types = player_stats.shot_types
	PlayerStats.ammo_counts = player_stats.ammo_counts

func load_player_position(player_position):
	var player = get_tree().root.find_child("Player", true, false)
	player.global_position.x = player_position.x
	player.global_position.y = player_position.y
	
	# update camera position
	var camera = player.find_child("Camera2D")
	camera.set_position_smoothing_enabled(false)
	camera.global_position = player.global_position
	await get_tree().idle_frame
	camera.set_position_smoothing_enabled(true)

# place holder function for when the world gets more complex
func load_world(world_data):
	load_room_map(world_data.room_map)

func load_room_map(room_map):
	var floor_generator = get_tree().root.find_child("FloorGenerator", true, false)
	floor_generator.flush_room_map()
	for room in room_map:
		load_room(room_map[room], floor_generator)

func load_room(room_data, floor_generator):
	var room_inst = floor_generator.create_room(room_data.x, room_data.y, false)
	room_inst.visited = room_data.visited
	load_enemies(room_inst, room_data.enemies, floor_generator)

func load_enemies(room_inst, enemies, floor_generator):
	for e in enemies:
		floor_generator.instanstiate_entity(room_inst, enemies[e].position, load(enemies[e].enemy_type))

func continue_save():
	init_game()
	call_deferred("load_data")

func init_game():
# warning-ignore:return_value_discarded
	get_tree().change_scene_to_file("res://Scenes/dungeon_scene.tscn")
	PlayerStats.initialise()

func save_exists():
	return FileAccess.file_exists(SAVE_FILE_PATH)
