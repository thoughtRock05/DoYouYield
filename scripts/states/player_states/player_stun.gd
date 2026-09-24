extends State
class_name PlayerStun

func enter_state(_msg := {}) -> void:
	player.player_sprite.play("hurt")

func physics_update(delta: float) -> void:
	player.knock_v.x = move_toward(player.knock_v.x, 0.0, player.KNOCKBACK_DECEL * delta)
	player.velocity.x = player.knock_v.x
	player.add_gravity(delta)
