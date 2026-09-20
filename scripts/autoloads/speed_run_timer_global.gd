extends Node

var is_speedrunning: bool = false
var time: float

func _ready() -> void:
	_reset()

func _reset() -> void:
	time = 0.0

func _physics_process(delta: float) -> void:
	if is_speedrunning:
		time += delta
