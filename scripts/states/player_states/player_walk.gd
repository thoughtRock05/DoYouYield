extends State
class_name PlayerWalk


func enter_state(_msg := {}) -> void:
	actor.player_sprite.play("walk")

func physics_update(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	if dir != 0:
		actor.velocity.x = dir * actor.SPEED
	actor.add_gravity(delta)
	
	if not actor.sfx_player_walk.is_playing() and actor.is_on_floor():
		actor.sfx_player_walk.play()
	
	if actor.is_on_floor():
		actor.jump_count = 0
		actor.coyote_timer.start()
	
	if actor.check_inputs():
		return
	elif Input.is_action_just_pressed("jump") or (not actor.coyote_timer.is_stopped() and not actor.buffer_timer.is_stopped()):
		actor.jump()
	elif dir == 0.0:
		state_machine.change_state("PlayerIdle")
	elif not actor.is_on_floor():
		state_machine.change_state("PlayerFall")
