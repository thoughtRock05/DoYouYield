extends Node2D

func _ready() -> void:
	await get_tree().process_frame
	SignalBus.change_menu_state.emit("MenuResults")
