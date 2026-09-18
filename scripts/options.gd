extends Node2D

@export var main_menu: StringName = &""
@export var back_button: Button

func _ready() -> void:
	back_button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	SceneTransition.load_scene(main_menu)
