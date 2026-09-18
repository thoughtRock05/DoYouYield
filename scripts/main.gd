extends Node2D

@export var music_controller: MusicController

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	#music_controller.switch_player.bind(p)
