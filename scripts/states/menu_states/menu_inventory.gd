extends MenuState
class_name MenuInventory

@onready var menu : Control = _menu as Control

func enter_state(_msg: Dictionary = {}) -> void:
	menu.visible = true

func exit_state() -> void:
	menu.visible = true

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
