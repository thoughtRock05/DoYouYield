extends State
class_name PlayerWallSlide

func enter_state(_msg := {}) -> void:
	player.player_sprite.play("wall_cling")

func exit_state() -> void:
	if player.sfx_player_wall_slide.is_playing():
		player.sfx_player_wall_slide.stop()

func physics_update(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	if not player.sfx_player_wall_slide.is_playing():
		player.sfx_player_wall_slide.play()
	
	player.velocity.y = min(player.velocity.y, player.WALL_SLIDE_SPEED)
	player.add_gravity(delta)
	
	if Input.is_action_just_pressed("jump"):
		var wall_normal = player.get_wall_normal()
		player.velocity.y = player.WALL_JUMP_VELOCITY
		player.velocity.x = wall_normal.x * player.WALL_JUMP_PUSH
		player.jump_count = 1
		player.wall_jump_timer.start()
		state_machine.change_state("PlayerJump")
	elif dir == 0 or sign(dir) == sign(player.get_wall_normal().x):
		player.velocity.x = player.get_wall_normal().x * player.WALL_DETATCH
		state_machine.change_state("PlayerFall")
	elif player.is_on_floor():
		state_machine.change_state("PlayerIdle")
	elif not player.is_on_wall():
		await player.wall_slide_timer.timeout
		state_machine.change_state("PlayerFall")
