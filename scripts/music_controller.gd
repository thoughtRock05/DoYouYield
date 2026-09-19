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
@export var ost_room_0_isolated: AudioStreamPlayer
@export var ost_room_1_isolated: AudioStreamPlayer
@export var ost_room_2_isolated: AudioStreamPlayer
@export var ost_room_3_isolated: AudioStreamPlayer
@export var ost_room_4_isolated: AudioStreamPlayer
@export var ost_room_5_isolated: AudioStreamPlayer
@export var ost_room_6_isolated: AudioStreamPlayer

@export var fade_time: float = 1.25

var players: Array[AudioStreamPlayer] = []

var current_player: int = 7

func _enter_tree() -> void:
	Music.instance = self

func _exit_tree() -> void:
	if Music.instance == self:
		Music.instance = null

func _ready() -> void:
	players = [
		player_0, 
		player_1, 
		player_2, 
		player_3, 
		player_4, 
		player_5, 
		player_6, 
		menu_music,
		ost_room_0_isolated,
		ost_room_1_isolated,
		ost_room_2_isolated,
		ost_room_3_isolated,
		ost_room_4_isolated,
		ost_room_5_isolated,
		]
	
	for i in range(players.size()):
		if i == current_player:
			players[i].volume_db = 0.0
		else:
			players[i].volume_db = -80.0
		players[i].play()

func switch_player(p: int) -> void:
	if p < 0 or p > 13:
		return
	var next_player = p
	
	players[next_player].volume_db = -80.0
	
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(players[current_player], "volume_db", -80.0, fade_time)
	tween.tween_property(players[next_player], "volume_db", 0.0, fade_time)
	
	current_player = next_player
