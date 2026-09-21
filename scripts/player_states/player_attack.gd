extends State
class_name PlayerAttack

func enter_state(_msg := {}) -> void:
	player.sfx_sword_swing.play()
	player.player_sprite.play("attack")

func exit_state() -> void:
	player.sword_hit_box.set_deferred("monitorable", false)
	player.sword_hit_box.set_deferred("monitoring", false)

func physics_update(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	player.add_gravity(delta)
	
	if abs(player.velocity.x) > player.DASH_ATTACK_SPEED or not player.is_on_floor():
		player.velocity.x = move_toward(player.velocity.x, dir * player.SPEED, player.ATTACK_DECEL * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.WALK_DECEL * delta)
	
	if not player.player_sprite.is_playing() or player.player_sprite.animation != "attack":
		state_machine.change_state("PlayerIdle")
