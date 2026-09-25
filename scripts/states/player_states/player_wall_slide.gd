extends State
class_name PlayerWallSlide

var actor: Player = _actor as Player

func enter_state(_msg := {}) -> void:
	actor.player_sprite.play("wall_cling")

func exit_state() -> void:
	if actor.sfx_player_wall_slide.is_playing():
		actor.sfx_player_wall_slide.stop()

func physics_update(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	if not actor.sfx_player_wall_slide.is_playing():
		actor.sfx_player_wall_slide.play()
	
	actor.velocity.y = min(actor.velocity.y, actor.WALL_SLIDE_SPEED)
	actor.add_gravity(delta)
	
	if Input.is_action_just_pressed("jump"):
		var wall_normal = actor.get_wall_normal()
		actor.velocity.y = actor.WALL_JUMP_VELOCITY
		actor.velocity.x = wall_normal.x * actor.WALL_JUMP_PUSH
		actor.jump_count = 1
		actor.wall_jump_timer.start()
		state_machine.change_state("PlayerJump")
	elif dir == 0 or sign(dir) == sign(actor.get_wall_normal().x):
		actor.velocity.x = actor.get_wall_normal().x * actor.WALL_DETATCH
		state_machine.change_state("PlayerFall")
	elif actor.is_on_floor():
		state_machine.change_state("PlayerIdle")
	elif not actor.is_on_wall():
		await actor.wall_slide_timer.timeout
		state_machine.change_state("PlayerFall")
