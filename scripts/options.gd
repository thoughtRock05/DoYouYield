extends Node2D

@export var main_menu: StringName = &""
@export var back_button: Button
@export var window_dropdown: OptionButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	back_button.grab_focus()

func _on_back_button_pressed() -> void:
	SceneTransition.load_scene(main_menu)
