extends Node2D
class_name CreditsScreen

func _ready() -> void:
	await SceneTransition.load_finished
	SignalBus.change_menu_state.emit("MenuResults")
