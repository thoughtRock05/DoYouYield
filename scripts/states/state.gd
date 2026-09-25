extends Node
class_name State

@warning_ignore("unused_private_class_variable") var _actor: CharacterBody2D
var state_machine: StateMachine

func enter_state(_msg: Dictionary = {}) -> void:
	pass

func exit_state() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
