extends Node2D

@export var trigger_area: Area2D
@export var next_room: String

func _ready() -> void:
	trigger_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		SceneTransition.load_scene(next_room)
