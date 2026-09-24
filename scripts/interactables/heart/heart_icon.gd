extends Sprite2D
class_name HeartIcon

var full_heart: CompressedTexture2D = preload("uid://bo30ovjpi0k8h")
var empty_heart: CompressedTexture2D = preload("uid://c3mawi0nlqfkt")

func full() -> void:
	texture = full_heart

func empty() -> void:
	texture = empty_heart
