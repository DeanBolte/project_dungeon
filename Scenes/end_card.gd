extends Control

@onready var SubTextVBox: VBoxContainer = $Main/SubTextContainer
@onready var ScoreTextLabel: Label = $Main/SubTextContainer/ScoreText

var MainMenuScene = "res://MainMenu/Menu.tscn"

@export var ACTION_DELAY_SECONDS = 1

var actionDelay = ACTION_DELAY_SECONDS

func _ready() -> void:
	SubTextVBox.visible = false
	getScores()

func _process(delta: float) -> void:
	if actionDelay > 0:
		actionDelay -= delta
	else:
		SubTextVBox.visible = true

func getScores():
	ScoreTextLabel.text = "
		Time: " + calcTime() + "
		Kills: " + str(PlayerStats.kills) + "
		Hits Taken: " + str(PlayerStats.hits_taken) + "\n
		" + getChallengesAchieved() + "
		Overall score: " + getOverallScore()

func getOverallScore():
	return str(PlayerStats.score - PlayerStats.hits_taken) 

func calcTime() -> String:
	var seconds = (Time.get_ticks_msec() - PlayerStats.start_time) / 1000
	var minutes = int(seconds / 60)
	return str(minutes) + " minutes " + str(seconds % 60) + " seconds"

func getChallengesAchieved() -> String:
	var challengeText = ""
	if PlayerStats.hits_taken <= 0:
		challengeText += "Challenge: No Damage Taken\n"
	if PlayerStats.kills <= 0:
		challengeText += "Challenge: Pacifist Run\n"
	return challengeText

func _input(event: InputEvent) -> void:
	if actionDelay <= 0:
		if not event is InputEventMouseMotion:
			get_tree().change_scene_to_file(MainMenuScene)
