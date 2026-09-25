extends Button
@export var sfx_player_jump: AudioStreamPlayer

func _pressed() -> void:
	sfx_player_jump.play()
