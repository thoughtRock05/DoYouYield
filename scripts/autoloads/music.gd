extends Node

var instance: MusicController = null

func switch_player(p: int) -> void:
	if instance:
		instance.switch_player(p)
