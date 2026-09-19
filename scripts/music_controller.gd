extends Node
class_name MusicController

@export var player_0: AudioStreamPlayer
@export var player_1: AudioStreamPlayer
@export var player_2: AudioStreamPlayer
@export var player_3: AudioStreamPlayer
@export var player_4: AudioStreamPlayer
@export var player_5: AudioStreamPlayer
@export var player_6: AudioStreamPlayer
@export var menu_music: AudioStreamPlayer

@export var fade_time: float = 0.75

var players: Array[AudioStreamPlayer] = []

var current_player: int = 7

func _enter_tree() -> void:
	Music.instance = self

func _exit_tree() -> void:
	if Music.instance == self:
		Music.instance = null

func _ready() -> void:
	players = [player_0, player_1, player_2, player_3, player_4, player_5, player_6, menu_music]
	
	for i in range(players.size()):
		if i == current_player:
			players[i].volume_db = 0.0
			players[i].play()
		else:
			players[i].volume_db = -80.0

func switch_player(p: int) -> void:
	if p < 0 or p > 7:
		return
	var next_player = p
	var position = players[current_player].get_playback_position()
	
	players[next_player].volume_db = -80.0
	players[next_player].play(position)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(players[current_player], "volume_db", -80.0, fade_time / 2.0)
	tween.tween_property(players[next_player], "volume_db", 0.0, fade_time)
	
	current_player = next_player
