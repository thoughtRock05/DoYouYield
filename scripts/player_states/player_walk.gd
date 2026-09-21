extends State
class_name PlayerWalk


func enter_state(_msg := {}) -> void:
	player.player_sprite.play("walk")

func physics_update(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	if dir != 0:
		player.velocity.x = dir * player.SPEED
	player.add_gravity(delta)
	
	if not player.sfx_player_walk.is_playing() and player.is_on_floor():
		player.sfx_player_walk.play()
	
	if player.is_on_floor():
		player.jump_count = 0
		player.coyote_timer.start()
	
	if player.check_inputs():
		return
	elif Input.is_action_just_pressed("jump") or (not player.coyote_timer.is_stopped() and not player.buffer_timer.is_stopped()):
		player.jump()
	elif dir == 0.0:
		state_machine.change_state("PlayerIdle")
	elif not player.is_on_floor():
		state_machine.change_state("PlayerFall")
