extends State
class_name PlayerDash

func enter_state(_msg := {}) -> void:
	var input_x: float = Input.get_axis("left", "right")
	if input_x != 0:
		player.dash_dir = Vector2(input_x, 0).normalized()
	else:
		var dash_x = -1 if player.player_sprite.flip_h else 1
		player.dash_dir = Vector2(dash_x, 0)
	
	if player.is_on_floor():
		player.current_dash = player.DashType.GROUND
	else:
		player.current_dash = player.DashType.AIR
	
	player.player_sprite.play("dash")
	player.can_dash = false
	player.velocity = player.dash_dir * player.DASH_SPEED
	player.velocity.y = 0
	
	if not player.sfx_player_dash.is_playing():
		player.sfx_player_dash.play()
	player.dash_timer.start(player.DASH_DURATION)

func physics_update(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	
	if Input.is_action_just_pressed("jump"):
		var max_jumps = 1 + int(player.has_double_jump)
		if not player.coyote_timer.is_stopped() or player.jump_count < max_jumps:
			player.dash_timer.stop()
			
			if player.current_dash == player.DashType.GROUND:
				player.current_dash = player.DashType.AIR
				player.can_dash = false
			player.jump()
			return
	
	if Input.is_action_just_pressed("attack") and player.has_sword:
		player.dash_timer.stop()
		if player.current_dash == player.DashType.GROUND:
				player.can_dash = true
				player.current_dash = player.DashType.AIR
		player.velocity = player.dash_dir * player.DASH_SPEED * 0.85
		state_machine.change_state("PlayerAttack")
		return
	
	if not player.dash_timer.is_stopped():
		player.velocity = player.dash_dir * player.DASH_SPEED
		player.velocity.y = 0
	else:
		player.add_gravity(delta)
		var target = dir * player.SPEED
		player.velocity.x = move_toward(player.velocity.x, target, player.DASH_DECEL * delta)
		
		if abs(player.velocity.x) > player.SPEED:
			if dir != 0:
				player.velocity.x = move_toward(player.velocity.x, dir * player.SPEED, player.DASH_DECEL * delta)
			else:
				player.velocity.x = move_toward(player.velocity.x, 0, player.DASH_DECEL * delta)
		
		if player.is_on_floor():
			if dir == 0.0:
				state_machine.change_state("PlayerIdle")
			else:
				state_machine.change_state("PlayerWalk")
		elif player.is_on_wall():
			state_machine.change_state("PlayerFall")
		else:
			state_machine.change_state("PlayerFall")
