extends Node2D

var heart_icon: PackedScene = preload("uid://b6gho8g43hlot")

func set_max_health(max_health: int) -> void:
	for child in get_children():
		if child is HeartIcon:
			child.queue_free()
	
	for idx in range(max_health):
		var heart: HeartIcon = heart_icon.instantiate() as HeartIcon
		add_child(heart)
		heart.position = Vector2(20 + (30 * idx * heart.scale.x), 16 * heart.scale.y)

func set_health(health: int) -> void:
	var idx: int = 0
	for child in get_children():
		if child is HeartIcon:
			if idx < health:
				child.full()
			else:
				child.empty()
			idx += 1
