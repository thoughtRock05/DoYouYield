extends Node2D

@export var main_menu: StringName = &""
@export var back_button: Button
@export var window_dropdown: OptionButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	window_dropdown.item_selected.connect(_on_window_dropdown_selected)

func _on_back_button_pressed() -> void:
	SceneTransition.load_scene(main_menu)

func _on_window_dropdown_selected(i: int) -> void:
	match i:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
