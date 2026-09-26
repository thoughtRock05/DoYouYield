extends State
class_name PlayerWallSlide

var actor: Player = _actor as Player
var is_waiting_to_fall: bool = false

func enter_state(_msg := {}) -> void:
	actor.player_sprite.play("wall_cling")
	is_waiting_to_fall = false
	actor.wall_slide_timer.stop()

func exit_state() -> void:
	if actor.sfx_player_wall_slide.is_playing():
		actor.sfx_player_wall_slide.stop()
	actor.wall_slide_timer.stop()

func physics_update(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	var wall_normal = actor.get_wall_normal()
	
	if not actor.sfx_player_wall_slide.is_playing():
		actor.sfx_player_wall_slide.play()
	
	actor.velocity.y = min(actor.velocity.y, actor.WALL_SLIDE_SPEED)
	actor.add_gravity(delta)
	
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("PlayerJump", {"wall_normal": wall_normal})
	elif actor.is_on_floor():
		state_machine.change_state("PlayerIdle")
	elif dir != 0 and sign(dir) == sign(wall_normal.x):
		if not is_waiting_to_fall:
			is_waiting_to_fall = true
			actor.wall_slide_timer.start()
			await actor.wall_slide_timer.timeout
			if is_waiting_to_fall:
				actor.velocity.x = wall_normal.x * actor.WALL_DETATCH
				state_machine.change_state("PlayerFall")
	elif not actor.is_on_wall():
		await actor.wall_slide_timer.timeout
		if not actor.is_on_wall():
			state_machine.change_state("PlayerFall")
