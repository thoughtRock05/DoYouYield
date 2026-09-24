extends State
class_name EnemyAlert

func enter_state(_msg := {}) -> void:
	if actor.sfx_aggro and not actor.is_alerted:
		actor.sfx_aggro.play()
	
	actor.is_alerting = true
	actor.is_alerted = true
	
	if actor.sprite.sprite_frames.has_animation("alert"):
		actor.sprite.play("alert")

	actor.get_tree().create_timer(0.5).timeout.connect(func():
		actor.is_alerting = false
	)

func physics_update(delta: float) -> void:
	if not actor.is_on_floor():
		actor.velocity.y += 980.0 * delta

	if actor.health <= 0:
		state_machine.change_state("EnemyDead")
		return

	if actor.is_stunned:
		state_machine.change_state("EnemyStunned")
		return

	if actor.target:
		var distance = (actor.target.position - actor.position).length()
		if distance > actor.max_threshold:
			actor.target = null
			state_machine.change_state("EnemyIdle")
			return
		
		if abs(actor.global_position.x - actor.target.position.x) > 0.2:
			actor.dir = sign(actor.target.position.x - actor.position.x)
			actor.velocity.x = actor.dir * actor.SPEED
		else:
			actor.velocity.x = 0.0

		if actor.velocity.x != 0:
			actor.sprite.flip_h = actor.velocity.x > 0

	actor.move_and_slide()
