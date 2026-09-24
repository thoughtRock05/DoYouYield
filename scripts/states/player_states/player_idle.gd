extends State
class_name PlayerIdle

func enter_state(_msg := {}) -> void:
	actor.player_sprite.play("idle")
	if actor.is_on_floor():
		actor.jump_count = 0
		actor.coyote_timer.start()

func physics_update(delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, actor.WALK_DECEL * delta)
	actor.add_gravity(delta)
	
	var dir = Input.get_axis("left", "right")
	
	if actor.check_inputs():
		return
	elif Input.is_action_just_pressed("jump") or (not actor.coyote_timer.is_stopped() and not actor.buffer_timer.is_stopped()):
		actor.jump()
	elif dir != 0.0:
		state_machine.change_state("PlayerWalk")
	elif not actor.is_on_floor():
		state_machine.change_state("PlayerFall")
