extends State
class_name PlayerJump

func enter_state(_msg := {}) -> void:
	player.player_sprite.play("jump")

func physics_update(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	if player.wall_jump_timer.is_stopped():
		player.velocity.x = dir * player.SPEED
	player.add_gravity(delta)
	
	if Input.is_action_just_pressed("dash") and player.has_dash and player.can_dash:
		state_machine.change_state("PlayerDash")
	elif Input.is_action_just_pressed("attack") and player.has_sword:
		state_machine.change_state("PlayerAttack")
	elif Input.is_action_just_pressed("jump") and player.jump_count < 1 + int(player.has_double_jump):
		player.jump()
	elif player.has_wall_jump and not player.is_on_floor() and player.is_on_wall() and player.velocity.y > 0:
		state_machine.change_state("PlayerWallSlide")
	elif player.velocity.y >= 0:
		state_machine.change_state("PlayerFall")
	elif player.is_on_floor():
		if dir == 0.0:
			state_machine.change_state("PlayerIdle")
		else:
			state_machine.change_state("PlayerWalk")
