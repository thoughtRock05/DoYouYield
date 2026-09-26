extends MenuState
class_name MenuResults

@onready var menu : Control = _menu as Control

@export var main_menu: Button
@export var quit: Button
@export var time_label: Label

func enter_state(msg: Dictionary = {}) -> void:
	super.enter_state(msg)
	get_tree().paused = true
	time_label.visible = SpeedRunTimerGlobal.is_speedrunning
	SpeedRunTimerGlobal.is_paused = true
	
	time_label.text = "%.2f" % SpeedRunTimerGlobal.time
	
	if not main_menu.pressed.is_connected(_on_main_menu):
		main_menu.pressed.connect(_on_main_menu)
		quit.pressed.connect(_on_quit)
	main_menu.grab_focus()

func _on_main_menu() -> void:
	SaveLoad.reset_save()
	SpeedRunTimerGlobal._reset()
	state_machine.change_state("MenuMain", {"previous_state": "MenuResults"})

func _on_quit() -> void:
	get_tree().quit()
