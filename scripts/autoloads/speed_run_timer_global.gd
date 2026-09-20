extends Node

var is_speedrunning: bool = false
var is_paused: bool = false
var time: float

func _ready() -> void:
	_reset()

func _reset() -> void:
	time = 0.0

func _physics_process(delta: float) -> void:
	if is_speedrunning and not is_paused:
		time += delta
		time = snapped(time, 0.01)
