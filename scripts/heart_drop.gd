extends RigidBody2D

@export var animated_sprite_2d: AnimatedSprite2D
@export var audio_stream_player: AudioStreamPlayer

func _ready() -> void:
	animated_sprite_2d.play()
	audio_stream_player.play()
