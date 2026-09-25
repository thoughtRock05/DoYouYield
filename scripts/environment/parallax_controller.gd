extends Node2D
class_name ParallaxController

func set_tiles(tiles_x: int, tiles_y: int) -> void:
	for child in get_children():
		if child is RoomParallax:
			child.room_tiles_x = tiles_x
			child.room_tiles_y = tiles_y
