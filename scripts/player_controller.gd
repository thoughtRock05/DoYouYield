extends CharacterBody2D
class_name Player

signal reset_room

const SPEED = 250.0
const JUMP_VELOCITY = -400.0
var max_health: int = 5
var health: int = 5
var can_move: bool = true

@export var coyote_timer: Timer
@export var buffer_timer: Timer

func _physics_process(delta: float) -> void:
	if can_move:
		calculate_velocity(delta)
		animate()
		move_and_slide()

func calculate_velocity(delta: float) -> void:	
	add_gravity(delta)
	jump_logic()
	attack_logic()
	move_left_right()

func add_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func jump_logic():
	if is_on_floor():
		coyote_timer.start()
	
	if Input.is_action_just_pressed("jump"):
		buffer_timer.start()
	
	if not coyote_timer.is_stopped() and not buffer_timer.is_stopped():
		jump()
		coyote_timer.stop()
		buffer_timer.stop()

func jump():
	velocity.y = JUMP_VELOCITY
	#$Sound.play_jump()

func attack_logic():
	if Input.is_action_just_pressed("attack"):
		#$AnimationPlayer.play_animation("HeavyAttack")
		pass

func move_left_right():
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func animate():
	if velocity.x < 0:
		#is_look_left = true
		pass
	elif velocity.x > 0:
		#is_look_left = false
		pass

	#face_good_direction()	
	if not is_on_floor():
		if velocity.y < 0:
			#$AnimationPlayer.play_animation("FlyUp")
			pass
		else:
			#$AnimationPlayer.play_animation("FlyBottom")
			pass
		return
	
	if velocity.x == 0:
		#$AnimationPlayer.play_animation("Idle")
		pass
		return
	
	#$AnimationPlayer.play_animation("Running")

#func face_good_direction() -> void:
	#if is_look_left:
		#var new_value = ($Sprite2D.scale.x - ROTATION_SPEED)
		#new_value = [new_value, -1].max()
		#$Sprite2D.scale.x = new_value
		#$CollisionShape2D.scale.x = new_value
		#$CollisionShape2D.position.x = abs($CollisionShape2D.position.x)
		#$HitBoxArea.scale.x = new_value
		#$HitBoxArea.position.x = abs($HitBoxArea.position.x)
		#$AttackArea.position.x = -abs($AttackArea.position.x)
	#else:
		#var new_value = ($Sprite2D.scale.x + ROTATION_SPEED)
		#new_value = [new_value, 1].min()
		#$Sprite2D.scale.x = new_value
		#$CollisionShape2D.scale.x = new_value
		#$CollisionShape2D.position.x = -abs($CollisionShape2D.position.x)
		#$HitBoxArea.scale.x = new_value
		#$HitBoxArea.position.x = -abs($HitBoxArea.position.x)
		#$AttackArea.position.x = abs($AttackArea.position.x)

func hit():
	#$Sound.play_hit()
	health =- 1
	if health <= 0:
		kill()

func health_pickup():
	#$Sound.play_health_pickup()
	health += 1
	if health > max_health:
		health = max_health

func kill() -> void:
	#$Sound.play_die()
	#$AnimationPlayer.play_animation("Die")
	
	await get_tree().create_timer(1.5).timeout
	reset_room.emit()
