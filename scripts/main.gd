extends Node2D

@export var music_controller: MusicController
@export var menu_state_machine: MenuStateMachine

func _ready() -> void:
	SignalBus.change_menu_state.connect(_on_change_menu_state)

func _on_change_menu_state(state: String):
	menu_state_machine.change_state(state)
