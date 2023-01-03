extends Node

const SAVE_FILE_PATH = "user://save_file.save"
var game_data = {}

func _ready():
	pass

func save_data():
	var file := File.new()
	file.open(SAVE_FILE_PATH, File.WRITE)
	file.store_var(save_player_stats())
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

func load_data():
	var file := File.new()
	if not file.file_exists(SAVE_FILE_PATH):
		return # no save file to load
	
	#var save_nodes = get_tree().get_nodes_in_group("Persist")
	file.open(SAVE_FILE_PATH, File.READ)
	load_player_stats(file.get_var())
	file.close()

func load_player_stats(player_stats):
	PlayerStats.max_health = player_stats.max_health
	PlayerStats.health = player_stats.health
	PlayerStats.max_clip = player_stats.max_clip
	PlayerStats.clip = player_stats.clip
	PlayerStats.selected_shot_type = player_stats.selected_shot_type
	PlayerStats.shot_types = player_stats.shot_types
	PlayerStats.ammo_counts = player_stats.ammo_counts
