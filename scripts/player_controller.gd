extends CharacterBody2D
class_name Player

signal reset_room

const SPEED = 250.0
const JUMP_VELOCITY = -400.0
const WALL_JUMP_VELOCITY = -380.0
const WALL_JUMP_PUSH = 350.0
const WALL_SLIDE_SPEED = 120.0
const DASH_SPEED = 900.0
const DASH_DURATION = 0.15

var can_move: bool = true
var max_health: int
var has_double_jump: bool
var has_wall_jump: bool
var has_sword: bool
var has_shield: bool
var has_dash: bool


@export var coyote_timer: Timer
@export var buffer_timer: Timer
@export var dash_timer: Timer

var jump_count = 0
var health: int
var is_wall_jumping: bool = false
var can_dash: bool = true
var is_dashing: bool = false
var dash_dir: Vector2 = Vector2.RIGHT

func _ready() -> void:
	has_double_jump = SaveLoad.get_key_value(SaveLoad.double_jump_key)
	has_wall_jump = SaveLoad.get_key_value(SaveLoad.wall_jump_key)
	has_sword = SaveLoad.get_key_value(SaveLoad.sword_key)
	has_shield = SaveLoad.get_key_value(SaveLoad.shield_key)
	has_dash = SaveLoad.get_key_value(SaveLoad.dash_key)

func _physics_process(delta: float) -> void:
	if can_move:
		calculate_velocity(delta)
		animate()
		move_and_slide()

func calculate_velocity(delta: float) -> void:	
	dash_logic()
	if is_dashing:
		velocity = dash_dir * DASH_SPEED
		return
	add_gravity(delta)
	wall_slide_logic()
	jump_logic()
	wall_jump_logic()
	attack_logic()
	move_left_right()

func dash_logic():
	if not has_dash:
		return
	var input_x: float = Input.get_axis("left", "right")
	if input_x != 0:
		dash_dir = Vector2(input_x, 0).normalized()
	
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		is_dashing = true
		can_dash = false
		velocity.y = 0
		get_tree().create_timer(DASH_DURATION).timeout.connect(func():
			is_dashing = false
			velocity.x = 0
		)
		
		get_tree().create_timer(DASH_DURATION + 0.5).timeout.connect(func():
			can_dash = true
		)

func add_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func wall_slide_logic() -> void:
	if not has_wall_jump:
		return
	if not is_on_floor() and is_on_wall() and velocity.y > 0:
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)

func wall_jump_logic() -> void:
	if not has_wall_jump:
		return
	if Input.is_action_just_pressed("jump") and not is_on_floor() and is_on_wall():
		var wall_normal = get_wall_normal()
		velocity.y = WALL_JUMP_VELOCITY
		velocity.x = wall_normal.x * WALL_JUMP_PUSH
		is_wall_jumping = true
		get_tree().create_timer(0.15).timeout.connect(func(): is_wall_jumping = false)
		jump_count = 1
		buffer_timer.stop()

func jump_logic():
	if is_on_floor():
		jump_count = 0
		coyote_timer.start()
		can_dash = true
	
	if Input.is_action_just_pressed("jump"):
		if not is_on_floor() and coyote_timer.is_stopped() and jump_count < 1 + int(has_double_jump):
			jump()
		else:
			buffer_timer.start()
	
	if not coyote_timer.is_stopped() and not buffer_timer.is_stopped():
		jump()
		coyote_timer.stop()
		buffer_timer.stop()

func jump():
	velocity.y = JUMP_VELOCITY
	jump_count += 1
	#$Sound.play_jump()

func attack_logic():
	if Input.is_action_just_pressed("attack"):
		#$AnimationPlayer.play_animation("HeavyAttack")
		pass

func move_left_right():
	if is_wall_jumping:
		return
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
