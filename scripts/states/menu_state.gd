extends State
class_name MenuState

@export @warning_ignore("unused_private_class_variable") var _menu: Control

func enter_state(_msg: Dictionary = {}) -> void:
	if _menu:
		_menu.visible = true

func exit_state() -> void:
	if _menu:
		_menu.visible = false
