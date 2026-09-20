extends Area2D
class_name AcidPit
@export var sfx_acid_bubble_pop: AudioStreamPlayer2D

func _process(_delta: float) -> void:
	if randf_range(1,100) < 30:
		if not sfx_acid_bubble_pop.playing: 
			sfx_acid_bubble_pop.play()
