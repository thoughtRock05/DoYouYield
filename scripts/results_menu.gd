extends Node2D

@export var main_menu: StringName = &""
@export var main_menu_button: Button
@export var quit_button: Button

func _ready() -> void:
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_main_menu_button_pressed() -> void:
	SceneTransition.load_scene(main_menu)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
