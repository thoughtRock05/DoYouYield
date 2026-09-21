extends State
class_name PlayerDead

func enter_state(_msg := {}) -> void:
	player.player_sprite.play("die")

func physics_update(delta: float) -> void:
	player.add_gravity(delta)
