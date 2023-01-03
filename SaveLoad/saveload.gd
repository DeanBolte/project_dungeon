extends Node

const SAVE_FILE_PATH = "user://save_file.save"
var game_data = {}

var packed_baseroom = load("res://Generation/RoomBase.tscn")

func _ready():
	pass

func save_data():
	var file := File.new()
	file.open(SAVE_FILE_PATH, File.WRITE)
	
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
	var player = get_tree().root.find_node("Player", true, false)
	var player_position = {
		"x" : player.position.x,
		"y" : player.position.y
	}
	return player_position

func save_world():
	var world_data = {
		"room_map" : save_room_map()
	}
	return world_data

func save_room_map():
	var room_data = get_tree().root.find_node("FloorGenerator", true, false)
	var room_map := Dictionary()
	for room in room_data.roomMap:
		room_map[room] = save_room(room_data.roomMap[room])
	return room_map

func save_room(room_inst):
	var room = {
		"x" : room_inst.MAP_LOCATION.x,
		"y" : room_inst.MAP_LOCATION.y,
		"enemies" : save_enemies()
	}
	return room

func save_enemies():
	pass

func load_data():
	var file := File.new()
	if not file.file_exists(SAVE_FILE_PATH):
		return # no save file to load
	
	#var save_nodes = get_tree().get_nodes_in_group("Persist")
	file.open(SAVE_FILE_PATH, File.READ)
	
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
	var player = get_tree().root.find_node("Player", true, false)
	player.position.x = player_position.x
	player.position.y = player_position.y

# place holder function for when the world gets more complex
func load_world(world_data):
	load_room_map(world_data.room_map)

func load_room_map(room_map):
	var floor_generator = get_tree().root.find_node("FloorGenerator", true, false)
	for room in room_map:
		load_room(room_map[room], floor_generator)

func load_room(room_data, floor_generator):
	var room_inst = floor_generator.create_room(room_data.x, room_data.y, false)

func continue_save():
	init_game()
	call_deferred("load_data")

func init_game():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/dungeon_scene.tscn")
	PlayerStats.initialise()

func save_exists():
	var file := File.new()
	return file.file_exists(SAVE_FILE_PATH)
