extends State
class_name PlayerShield

func enter_state(_msg := {}) -> void:
	actor.player_sprite.play("idle")

func physics_update(delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, actor.ATTACK_DECEL * delta)
	actor.add_gravity(delta)
	
	if not Input.is_action_pressed("shield") or not actor.has_shield or actor.in_menu:
		state_machine.change_state("PlayerIdle")
