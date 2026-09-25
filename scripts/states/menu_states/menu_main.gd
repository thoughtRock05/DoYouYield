extends MenuState
class_name MenuMain

@onready var menu : Control = _menu as Control

@export_file("*.tscn") var title_screen: String
@export_file("*.tscn") var initial_scene: String
@export var play: Button
@export var options: Button
@export var quit: Button

func enter_state(msg: Dictionary = {}) -> void:
	get_tree().paused = false
	SpeedRunTimerGlobal.is_paused = true
	if msg.has("previous_state"):
		await SceneTransition.load_scene(title_screen)
	menu.visible = true
	if not play.pressed.is_connected(_on_play):
		play.pressed.connect(_on_play)
		options.pressed.connect(_on_options)
		quit.pressed.connect(_on_quit)
	play.grab_focus()

func _on_play() -> void:
	state_machine.change_state("MenuNone")
	SceneTransition.load_scene(initial_scene)

func _on_options() -> void:
	state_machine.change_state("MenuSettings", {"previous_state": "MenuMain"})

func _on_quit() -> void:
	get_tree().quit()
