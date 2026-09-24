extends Control

@export var label: Label

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	label.visible = SpeedRunTimerGlobal.is_speedrunning
	label.text = "%.2f" % SpeedRunTimerGlobal.time
