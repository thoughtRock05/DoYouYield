extends EnemyAlert
class_name SlimeAlert

func enter_state(_msg := {}) -> void:
	super.enter_state(_msg)
	actor.sprite.self_modulate = Color(0.939, 0.001, 0.073, 1.0)

func exit_state() -> void:
	super.exit_state()
	actor.sprite.self_modulate  = Color(1.0, 1.0, 1.0, 1.0)
