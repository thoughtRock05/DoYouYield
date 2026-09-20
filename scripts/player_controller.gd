extends CharacterBody2D
class_name Player

signal reset_room
signal set_health(health: int)
@warning_ignore("unused_signal") signal set_max_health(max_health: int)

const SPEED = 250.0
const JUMP_VELOCITY = -315.0
const WALL_JUMP_VELOCITY = -380.0
const WALL_JUMP_PUSH = 150.0
const WALL_SLIDE_SPEED = 90.0
const DASH_SPEED = 600.0
const DASH_DURATION = 0.015
const DASH_DECEL = 2500.0
const ATTACK_DECEL = 500.0
const KNOCKBACK_DECEL = 1200.0

var in_menu: bool = false
var can_move: bool = true

var has_double_jump: bool
var has_wall_jump: bool
var has_sword: bool
var has_shield: bool
var has_dash: bool

@export var player_camera: Camera2D
@export var coyote_timer: Timer
@export var buffer_timer: Timer
@export var dash_timer: Timer
@export var sword_hit_box: Area2D
@export var animated_sprite: AnimatedSprite2D
@export var i_frame_timer: Timer
@export var hitbox: Area2D
@export var shield_sprite: Sprite2D
@export var shield_collision: Area2D

@export var sfx_player_dash: AudioStreamPlayer
@export var sfx_player_death: AudioStreamPlayer
@export var sfx_player_hurt: AudioStreamPlayer
@export var sfx_player_jump: AudioStreamPlayer
@export var sfx_player_walk: AudioStreamPlayer
@export var sfx_player_walk_lower_pitch: AudioStreamPlayer
@export var sfx_player_wall_slide: AudioStreamPlayer
@export var sfx_heart_pickup: AudioStreamPlayer
@export var sfx_sword_swing: AudioStreamPlayer

var jump_count = 0
var health: int
var max_health: int
var is_wall_jumping: bool = false
var can_dash: bool = true
var is_dashing: bool = false
var dash_dir: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var is_invincible: bool = false
var is_dead: bool = false
var using_shield: bool = false
var is_stunned: bool = false
var knock_v: Vector2 = Vector2.ZERO

func _ready() -> void:
	has_double_jump = SaveLoad.get_key_value(SaveLoad.double_jump_key)
	has_wall_jump = SaveLoad.get_key_value(SaveLoad.wall_jump_key)
	has_sword = SaveLoad.get_key_value(SaveLoad.sword_key)
	has_shield = SaveLoad.get_key_value(SaveLoad.shield_key)
	has_dash = SaveLoad.get_key_value(SaveLoad.dash_key)
	
	max_health = SaveLoad.get_key_value(SaveLoad.max_health_key)
	health = max_health
	
	sword_hit_box.monitorable = false
	sword_hit_box.monitoring = false
	animated_sprite.frame_changed.connect(_on_frame_changed)
	hitbox.area_entered.connect(hit)
	animated_sprite.position.x = 11.0
	sword_hit_box.position.x = 30.0

func _physics_process(delta: float) -> void:
	if is_dead:
		add_gravity(delta)
		move_and_slide()
		return
	check_shield()
	calculate_velocity(delta)
	animate()
	move_and_slide()

func check_shield() -> void:
		if Input.is_action_pressed("shield"):
			if has_shield and not in_menu:
				using_shield = true
				can_move = false
		else:
			if not is_attacking:
				using_shield = false
			if Input.is_action_just_released("shield"):
				for child in shield_collision.get_overlapping_areas():
					hit(child)
				if is_dashing or is_attacking or is_stunned or in_menu:
					return
				can_move = true

func calculate_velocity(delta: float) -> void:	
	dash_logic()
	if is_dashing:
		velocity = dash_dir * DASH_SPEED
		return
	add_gravity(delta)
	knockback_logic(delta)
	wall_slide_logic()
	jump_logic()
	wall_jump_logic()
	attack_logic()
	move_left_right(delta)

func dash_logic():
	if not has_dash or not can_move:
		return
	var input_x: float = Input.get_axis("left", "right")
	if input_x != 0 and not is_dashing:
		dash_dir = Vector2(input_x, 0).normalized()
	
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		animated_sprite.play("dash")
		is_dashing = true
		can_dash = false
		velocity.y = 0
		if not sfx_player_dash.is_playing():
			sfx_player_dash.play()
		velocity = dash_dir * DASH_SPEED
		
		get_tree().create_timer(DASH_DURATION).timeout.connect(func():
			is_dashing = false
		)
		
		get_tree().create_timer(DASH_DURATION + 0.5).timeout.connect(func():
			can_dash = true
		)

func add_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func knockback_logic(delta: float) -> void:
	if is_stunned:
		knock_v.x = move_toward(knock_v.x, 0.0, KNOCKBACK_DECEL * delta)
		velocity.x = knock_v.x
		get_tree().create_timer(0.5).timeout.connect(func():
			is_stunned = false
			)
		return

func wall_slide_logic() -> void:
	if not has_wall_jump or not can_move:
		return
	if not is_on_floor() and is_on_wall() and velocity.y > 0:
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
		if not sfx_player_wall_slide.is_playing():
			sfx_player_wall_slide.play()

func wall_jump_logic() -> void:
	if not has_wall_jump or not can_move:
		return
	if Input.is_action_just_pressed("jump") and not is_on_floor() and is_on_wall():
		if sfx_player_wall_slide.is_playing():
			sfx_player_wall_slide.stop()
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
	
	if Input.is_action_just_pressed("jump"):
		if not is_on_floor() and coyote_timer.is_stopped() and jump_count < 1 + int(has_double_jump) and can_move:
			jump()
		else:
			buffer_timer.start()
	
	if not coyote_timer.is_stopped() and not buffer_timer.is_stopped() and can_move:
		jump()
		coyote_timer.stop()
		buffer_timer.stop()

func jump():
	velocity.y = JUMP_VELOCITY
	jump_count += 1
	animated_sprite.play("jump")
	if not sfx_player_jump.is_playing():
		sfx_player_jump.play()

func attack_logic():
	if not has_sword or not can_move:
		return
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true 
		can_move = false
		sfx_sword_swing.play()
		animated_sprite.play("attack")
		await animated_sprite.animation_finished
		
		can_move = true
		is_attacking = false

func _on_frame_changed() -> void:
	if animated_sprite.animation == "attack":
		if animated_sprite.frame == 0:
			if abs(velocity.x) > SPEED and has_shield:
				using_shield = true
		if animated_sprite.frame == 1:
			sword_hit_box.monitoring = true
			sword_hit_box.monitorable = true
		if animated_sprite.frame == 2:
			sword_hit_box.get_overlapping_areas()
		if animated_sprite.frame == 3:
			sword_hit_box.monitoring = false
			sword_hit_box.monitorable = false
		if animated_sprite.frame == 4:
			if using_shield:
				using_shield = false

func move_left_right(delta):
	if is_wall_jumping or is_stunned:
		return
	var direction: float = 0.0
	if can_move:
		direction = Input.get_axis("left", "right")
	if is_dashing:
		return
	if is_attacking:
		velocity.x = move_toward(velocity.x, direction * SPEED, ATTACK_DECEL * delta)
	elif abs(velocity.x) > SPEED:
		velocity.x = move_toward(velocity.x, direction * SPEED, DASH_DECEL * delta)
	else:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

func animate():
	shield_sprite.visible = using_shield
	if is_dead or is_attacking:
		return
	if velocity.x < 0:
		animated_sprite.position.x = -8.0
		animated_sprite.flip_h = true
		sword_hit_box.position.x = -30.0
	elif velocity.x > 0:
		animated_sprite.position.x = 11.0
		animated_sprite.flip_h = false
		sword_hit_box.position.x = 30.0
	
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		elif velocity.y > 0:
			if is_on_wall():
				if has_wall_jump:
					animated_sprite.play("wall_cling")
			else:
				animated_sprite.play("fall")
		return
	
	if velocity.x == 0 and not is_attacking:
		animated_sprite.play("idle")
		return
	
	animated_sprite.play("walk")
	if not sfx_player_walk.is_playing():
		sfx_player_walk.play()

func hit(area: Area2D):
	if area is HeartBox:
		area.get_parent().queue_free()
		health_pickup()
		return
	if area is AcidPit:
		die()
		return
	if area is not EnemyHitBox:
		return
	if is_invincible or using_shield or is_dead:
		return
	if not sfx_player_hurt.is_playing():
		sfx_player_hurt.play()
	health -= 1
	set_health.emit(health)
	if health <= 0:
		die()
	else:
		animated_sprite.play("hurt")
		is_stunned = true
		is_attacking = false
		var knock_dir: float = sign(global_position.x - area.global_position.x)
		if knock_dir == 0.0:
			knock_dir = 1
		knock_v.x = knock_dir * 500.0
		velocity.y = -250.0
		
		is_invincible = true
		i_frame_timer.start()
		await i_frame_timer.timeout
		is_invincible = false
		is_stunned = true

func health_pickup():
	sfx_heart_pickup.play()
	health += 1
	if health > max_health:
		health = max_health
	set_health.emit(health)

func die() -> void:
	if not is_dead:
		set_health.emit(0)
		is_dead = true
		can_move = false
		velocity = Vector2(0.0, -200.0)
		sfx_player_death.play()
		animated_sprite.play("die")
	
	await animated_sprite.animation_finished
	reset_room.emit()

func set_camera_boundaries(x: int, y: int) -> void:
	var tile_size: int = 16
	player_camera.limit_top = 0
	player_camera.limit_bottom = y * tile_size
	player_camera.limit_left = 0
	player_camera.limit_right = x * tile_size
