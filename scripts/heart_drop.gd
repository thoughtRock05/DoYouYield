extends RigidBody2D

@export var animated_sprite_2d: AnimatedSprite2D

func _ready() -> void:
	animated_sprite_2d.play()
