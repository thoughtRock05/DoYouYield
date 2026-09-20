extends Node2D
class_name Lock

const DOOR_CLOSED = preload("uid://kyv1nm3ioy0")
const DOOR_OPEN = preload("uid://bk66uajxkaxfj")
@export var sprite_2d: Sprite2D

signal trigger_lock(room: String, take_heart, taken_item)
@export var trigger_area: Area2D
@export var next_room: String

var is_open: bool = false:
	set(value):
		is_open = value
		if is_open:
			sprite_2d.texture = DOOR_OPEN
		else:
			sprite_2d.texture = DOOR_CLOSED

func _ready() -> void:
	trigger_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		trigger_lock.emit(next_room)
