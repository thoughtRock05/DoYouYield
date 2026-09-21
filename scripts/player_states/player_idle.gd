extends State
class_name PlayerIdle

func enter_state(_msg := {}) -> void:
	player.player_sprite.play("idle")
	if player.is_on_floor():
		player.jump_count = 0
		player.coyote_timer.start()

func physics_update(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0, player.WALK_DECEL * delta)
	player.add_gravity(delta)
	
	var dir = Input.get_axis("left", "right")
	
	if player.check_inputs():
		return
	elif Input.is_action_just_pressed("jump") or (not player.coyote_timer.is_stopped() and not player.buffer_timer.is_stopped()):
		player.jump()
	elif dir != 0.0:
		state_machine.change_state("PlayerWalk")
	elif not player.is_on_floor():
		state_machine.change_state("PlayerFall")
