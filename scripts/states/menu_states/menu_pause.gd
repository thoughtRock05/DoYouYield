extends MenuState
class_name MenuPause

var menu : Control = _menu as Control

@export var resume: Button
@export var options: Button
@export var main_menu: Button
@export var reset: Button

func enter_state(msg: Dictionary = {}) -> void:
	super.enter_state(msg)
	get_tree().paused = true
	SpeedRunTimerGlobal.is_paused = true
	Music.switch_player(7)
	
	if not resume.pressed.is_connected(_on_resume):
		resume.pressed.connect(_on_resume)
		options.pressed.connect(_on_options)
		main_menu.pressed.connect(_on_main_menu)
		reset.pressed.connect(_on_reset)
		
	resume.grab_focus()

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("escape") or Input.is_action_just_pressed("back"):
		_on_resume()

func _on_resume() -> void:
	#CAUTION rooms gotta put the music back
	state_machine.change_state("MenuNone")

func _on_options() -> void:
	state_machine.change_state("MenuSettings", {"previous_state": "MenuPause"})

func _on_reset() -> void:
	state_machine.change_state("MenuNone")
	
	var current_room = get_tree().current_scene
	if current_room is Room:
		SceneTransition.load_scene(current_room.uid)

func _on_main_menu() -> void:
	SaveLoad.reset_save()
	SpeedRunTimerGlobal._reset()
	state_machine.change_state("MenuMain")
	SceneTransition.load_scene("uid://5pufmg2xnm6j")
