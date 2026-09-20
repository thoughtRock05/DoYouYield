extends Control

@export var label: Label

func _ready() -> void:
	label.visible = SpeedRunTimerGlobal.is_speedrunning

func _process(_delta: float) -> void:
	label.text = str(SpeedRunTimerGlobal.time)
