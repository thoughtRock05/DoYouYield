extends State
class_name PlayerShield

func enter_state(_msg := {}) -> void:
	player.player_sprite.play("idle")

func physics_update(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0, player.ATTACK_DECEL * delta)
	player.add_gravity(delta)
	
	if not Input.is_action_pressed("shield") or not player.has_shield or player.in_menu:
		state_machine.change_state("PlayerIdle")
