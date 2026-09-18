extends Node2D
class_name Lock

signal trigger_lock(room: String, take_heart, taken_item)
@export var trigger_area: Area2D
@export var next_room: String

func _ready() -> void:
	trigger_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		trigger_lock.emit(next_room)
