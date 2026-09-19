extends "res://scripts/room.gd"

@export var area_2d: Area2D

func _ready() -> void:
	super._ready()
	area_2d.monitoring = false
	area_2d.monitorable = false

func spawn_heart(pos: Vector2) -> void:
	super.spawn_heart(pos)
	area_2d.monitoring = true
	area_2d.monitorable = true
