extends PointLight2D

func _ready() -> void:
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "energy", 0.7, 3.5)
	tween.tween_property(self, "energy", 1.2, 3.5)
