extends Node2D

var full_heart: CompressedTexture2D = preload("uid://bo30ovjpi0k8h")
var empty_heart: CompressedTexture2D = preload("uid://c3mawi0nlqfkt")

func _ready() -> void:
	for child in get_children():
		if child is Sprite2D:
			child.show()
			child.texture = full_heart

func set_max_health(i: int) -> void:
	for child in get_children():
		if child is Sprite2D:
			if child.get_index() >= i:
				child.hide()
			else:
				child.show()

func set_health(i: int) -> void:
	for child in get_children():
		if child is Sprite2D:
			if child.get_index() < i:
				child.texture = full_heart
			else:
				child.texture = empty_heart
