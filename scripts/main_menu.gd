extends Node2D

@export var initial_scene: StringName = &""
@export var options_scene: StringName = &""
@export var play_button: Button
@export var options_button: Button

func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	options_button.pressed.connect(_on_options_menu_button_pressed)

func _on_play_button_pressed() -> void:
	SceneTransition.load_scene(initial_scene)

func _on_options_menu_button_pressed() -> void:
	SceneTransition.load_scene(options_scene)
