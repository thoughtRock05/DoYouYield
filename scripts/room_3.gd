extends "res://scripts/room.gd"

@export var area_2d: Area2D
@export var moving_platform_3: AnimatableBody2D

func _ready() -> void:
	super._ready()
	area_2d.monitoring = false
	area_2d.monitorable = false
	moving_platform_3.process_mode = Node.PROCESS_MODE_DISABLED

func spawn_heart(pos: Vector2) -> void:
	super.spawn_heart(pos)
	area_2d.monitoring = true
	area_2d.monitorable = true
	moving_platform_3.process_mode = Node.PROCESS_MODE_PAUSABLE
