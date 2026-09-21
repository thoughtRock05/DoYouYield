extends CharacterBody2D
class_name Player

signal reset_room
signal set_health(health: int)
@warning_ignore("unused_signal") signal set_max_health(max_health: int)

const SPEED = 250.0
const WALK_DECEL = 1200.0
const JUMP_VELOCITY = -315.0
const WALL_JUMP_VELOCITY = -380.0
const WALL_JUMP_PUSH = 150.0
const WALL_SLIDE_SPEED = 90.0
const DASH_SPEED = 500.0
const DASH_DURATION = 0.25
const DASH_DECEL = 2500.0
const ATTACK_DECEL = 700.0
const KNOCKBACK_DECEL = 1200.0
const I_FRAMES_DURATION = 0.5
const DASH_ATTACK_SPEED = 100.0

enum State {
	IDLE,
	WALK,
	JUMP,
	FALL,
	WALL_SLIDE,
	DASH,
	SHIELD,
	ATTACK,
	STUN,
	DEAD
}

var active_state: State = State.IDLE
var in_menu: bool = false

var has_double_jump: bool
var has_wall_jump: bool
var has_sword: bool
var has_shield: bool
var has_dash: bool

@export var player_sprite: AnimatedSprite2D
@export var player_camera: Camera2D
@export var player_hitbox: PlayerHitBox
@export var sword_hit_box: SwordHitBox
@export var shield_sprite: Sprite2D
@export var shield_collision: CollisionShape2D
@export var shield_hitbox: Area2D

@export var coyote_timer: Timer
@export var buffer_timer: Timer
@export var dash_timer: Timer
@export var wall_jump_timer: Timer
@export var attack_timer: Timer
@export var i_frame_timer: Timer

@export var sfx_player_dash: AudioStreamPlayer
@export var sfx_player_death: AudioStreamPlayer
@export var sfx_player_hurt: AudioStreamPlayer
@export var sfx_player_jump: AudioStreamPlayer
@export var sfx_player_walk: AudioStreamPlayer
@export var sfx_player_wall_slide: AudioStreamPlayer
@export var sfx_heart_pickup: AudioStreamPlayer
@export var sfx_sword_swing: AudioStreamPlayer

var can_move = true
var jump_count = 0
var health: int
var max_health: int
var can_dash: bool = true
var dash_dir: Vector2 = Vector2.RIGHT
var is_invincible: bool = false
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
	player_sprite.frame_changed.connect(_on_frame_changed)
	player_hitbox.area_entered.connect(hit)
	sword_hit_box.area_entered.connect(_on_sword_hit_box_area_entered)
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	i_frame_timer.timeout.connect(_on_i_frame_timer_timeout)
	player_sprite.position.x = 11.0
	sword_hit_box.position.x = 30.0

func _physics_process(delta: float) -> void:
	if not can_move:
		return
	
	check_camera(delta)
	
	if active_state == State.DEAD:
		add_gravity(delta)
		move_and_slide()
		return
	
	if active_state == State.IDLE:
		player_sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, WALK_DECEL * delta)
		add_gravity(delta)
		
		if is_on_floor():
			jump_count = 0
			coyote_timer.start()
		
		if Input.is_action_pressed("shield") and has_shield and not in_menu:
			change_state(State.SHIELD)
		elif Input.is_action_just_pressed("dash") and has_dash and can_dash:
			change_state(State.DASH)
		elif Input.is_action_just_pressed("attack") and has_sword:
			change_state(State.ATTACK)
		elif Input.is_action_just_pressed("jump") or (not coyote_timer.is_stopped() and not buffer_timer.is_stopped()):
			jump()
		elif Input.get_axis("left", "right") != 0.0:
			change_state(State.WALK)
		elif not is_on_floor():
			change_state(State.FALL)
	
	elif active_state == State.WALK:
		player_sprite.play("walk")
		var dir = Input.get_axis("left", "right")
		if dir != 0:
			velocity.x = dir * SPEED
		add_gravity(delta)
		
		if not sfx_player_walk.is_playing() and is_on_floor():
			sfx_player_walk.play()
		
		if is_on_floor():
			jump_count = 0
			coyote_timer.start()
		
		if Input.is_action_pressed("shield") and has_shield and not in_menu:
			change_state(State.SHIELD)
		elif Input.is_action_just_pressed("dash") and has_dash and can_dash:
			change_state(State.DASH)
		elif Input.is_action_just_pressed("attack") and has_sword:
			change_state(State.ATTACK)
		elif Input.is_action_just_pressed("jump") or (not coyote_timer.is_stopped() and not buffer_timer.is_stopped()):
			jump()
		elif dir == 0.0:
			change_state(State.IDLE)
		elif not is_on_floor():
			change_state(State.FALL)
	
	elif active_state == State.JUMP:
		player_sprite.play("jump")
		var dir = Input.get_axis("left", "right")
		if wall_jump_timer.is_stopped():
			velocity.x = dir * SPEED
		add_gravity(delta)
		
		if Input.is_action_just_pressed("dash") and has_dash and can_dash:
			change_state(State.DASH)
		elif Input.is_action_just_pressed("attack") and has_sword:
			change_state(State.ATTACK)
		elif Input.is_action_just_pressed("jump") and jump_count < 1 + int(has_double_jump):
			jump()
		elif has_wall_jump and not is_on_floor() and is_on_wall() and velocity.y > 0:
			change_state(State.WALL_SLIDE)
		elif velocity.y >= 0:
			change_state(State.FALL)
		elif is_on_floor():
			if dir == 0.0:
				change_state(State.IDLE)
			else:
				change_state(State.WALK)
	
	elif active_state == State.FALL:
		player_sprite.play("fall")
		var dir = Input.get_axis("left", "right")
		velocity.x = dir * SPEED
		add_gravity(delta)
		
		if Input.is_action_just_pressed("dash") and has_dash and can_dash:
			change_state(State.DASH)
		elif Input.is_action_just_pressed("attack") and has_sword:
			change_state(State.ATTACK)
		elif Input.is_action_just_pressed("jump") and (coyote_timer.is_stopped() == false or jump_count < 1 + int(has_double_jump)):
			jump()
			coyote_timer.stop()
		elif has_wall_jump and not is_on_floor() and is_on_wall() and velocity.y > 0:
			change_state(State.WALL_SLIDE)
		elif is_on_floor():
			jump_count = 0
			if dir == 0.0:
				change_state(State.IDLE)
			else:
				change_state(State.WALK)
		
	elif active_state == State.WALL_SLIDE:
		player_sprite.play("wall_cling")
		if not sfx_player_wall_slide.is_playing():
			sfx_player_wall_slide.play()
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
		add_gravity(delta)
		
		if Input.is_action_just_pressed("jump"):
			if sfx_player_wall_slide.is_playing():
				sfx_player_wall_slide.stop()
			var wall_normal = get_wall_normal()
			velocity.y = WALL_JUMP_VELOCITY
			velocity.x = wall_normal.x * WALL_JUMP_PUSH
			jump_count = 1
			wall_jump_timer.start()
			change_state(State.JUMP)
		elif is_on_floor():
			if sfx_player_wall_slide.is_playing():
				sfx_player_wall_slide.stop()
			change_state(State.IDLE)
		elif not is_on_wall():
			if sfx_player_wall_slide.is_playing():
				sfx_player_wall_slide.stop()
			change_state(State.FALL)

	elif active_state == State.DASH:
		if Input.is_action_just_pressed("attack") and has_sword:
			dash_timer.stop()
			can_dash = true
			velocity = dash_dir * DASH_SPEED * 0.85
			change_state(State.ATTACK)
			return
		
		if not dash_timer.is_stopped():
			velocity = dash_dir * DASH_SPEED
			velocity.y = 0
		else:
			add_gravity(delta)
			var dir = Input.get_axis("left", "right")
			var target = dir * SPEED
			velocity.x = move_toward(velocity.x, target, DASH_DECEL * delta)
			
			if abs(velocity.x) > SPEED:
				if dir != 0:
					velocity.x = move_toward(velocity.x, dir * SPEED, DASH_DECEL * delta)
				else:
					velocity.x = move_toward(velocity.x, 0, DASH_DECEL * delta)
			
			if is_on_floor():
				if dir == 0.0:
					change_state(State.IDLE)
				else:
					change_state(State.WALK)
			elif is_on_wall():
				change_state(State.FALL)

	elif active_state == State.SHIELD:
		player_sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, ATTACK_DECEL * delta)
		add_gravity(delta)
		if not Input.is_action_pressed("shield") or not has_shield or in_menu:
			for child in shield_hitbox.get_overlapping_areas():
				hit(child)
			change_state(State.IDLE)

	elif active_state == State.ATTACK:
		add_gravity(delta)
		if abs(velocity.x) > SPEED:
			velocity.x = move_toward(velocity.x, 0, ATTACK_DECEL * delta) 
		else:
			var dir = Input.get_axis("left","right")
			velocity.x = move_toward(velocity.x, dir * SPEED, ATTACK_DECEL * delta)
		
		if not player_sprite.is_playing() or player_sprite.animation != "attack":
			change_state(State.IDLE)

	elif active_state == State.STUN:
		player_sprite.play("hurt")
		knock_v.x = move_toward(knock_v.x, 0.0, KNOCKBACK_DECEL * delta)
		velocity.x = knock_v.x
		add_gravity(delta)

	update_facing()
	update_shield_visuals()
	move_and_slide()

func check_camera(delta) -> void:
	var look_y: float = 0
	if Input.is_action_pressed("up"):
		look_y -= 50
	elif Input.is_action_pressed("down"):
		look_y += 50
	player_camera.position.y = lerp(player_camera.position.y, look_y, 10 * delta)

func add_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func jump():
	velocity.y = JUMP_VELOCITY
	jump_count += 1
	player_sprite.play("jump")
	sfx_player_jump.play()
	change_state(State.JUMP)
	buffer_timer.stop()

func change_state(new_state: State) -> void:
	if active_state == State.ATTACK:
		sword_hit_box.set_deferred("monitorable", false)
		sword_hit_box.set_deferred("monitoring", false)

	active_state = new_state

	match active_state:
		State.IDLE:
			player_sprite.play("idle")
		State.WALK:
			player_sprite.play("walk")
		State.JUMP:
			player_sprite.play("jump")
		State.FALL:
			player_sprite.play("fall")
		State.WALL_SLIDE:
			player_sprite.play("wall_cling")
		State.DASH:
			var input_x: float = Input.get_axis("left", "right")
			if input_x != 0:
				dash_dir = Vector2(input_x, 0).normalized()
			else:
				var dash_x = -1 if player_sprite.flip_h else 1
				dash_dir = Vector2(dash_x, 0)
			
			player_sprite.play("dash")
			can_dash = false
			velocity = dash_dir * DASH_SPEED
			velocity.y = 0
			if not sfx_player_dash.is_playing():
				sfx_player_dash.play()
			dash_timer.start(DASH_DURATION)
		State.ATTACK:
			sfx_sword_swing.play()
			player_sprite.play("attack")
		State.SHIELD:
			player_sprite.play("idle")
		State.STUN:
			player_sprite.play("hurt")
		State.DEAD:
			player_sprite.play("die")

func _on_frame_changed() -> void:
	if player_sprite.animation == "dash":
		var last_frame: int = player_sprite.sprite_frames.get_frame_count("dash") - 1
		if player_sprite.frame == last_frame:
			player_sprite.pause()
	
	if player_sprite.animation == "attack":
		if player_sprite.frame == 2:
			sword_hit_box.monitoring = true
			sword_hit_box.monitorable = true
		if player_sprite.frame == 4:
			sword_hit_box.monitoring = false
			sword_hit_box.monitorable = false

func update_facing():
	if active_state == State.DASH or active_state == State.ATTACK or active_state == State.DEAD:
		return
	if velocity.x < 0:
		player_sprite.position.x = -8.0
		player_sprite.flip_h = true
		sword_hit_box.position.x = -30.0
	elif velocity.x > 0:
		player_sprite.position.x = 11.0
		player_sprite.flip_h = false
		sword_hit_box.position.x = 30.0

func update_shield_visuals():
	var shielding = (active_state == State.SHIELD) or (active_state == State.ATTACK and abs(velocity.x) > DASH_ATTACK_SPEED)
	shield_sprite.visible = shielding
	shield_collision.disabled = not shielding
	shield_hitbox.monitorable = shielding
	shield_hitbox.monitoring = shielding

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
	if is_invincible or active_state == State.SHIELD or active_state == State.DEAD or (active_state == State.ATTACK and abs(velocity.x) > DASH_ATTACK_SPEED):
		return
	if not sfx_player_hurt.is_playing():
		sfx_player_hurt.play()
	
	health -= 1
	set_health.emit(health)
	
	if health <= 0:
		die()
	else:
		if active_state == State.DASH:
			dash_timer.stop()
			can_dash = true
		
		change_state(State.STUN)
		var knock_dir: float = sign(global_position.x - area.global_position.x)
		if knock_dir == 0.0:
			knock_dir = 1
		knock_v.x = knock_dir * 500.0
		velocity.y = -250.0
		
		is_invincible = true
		i_frame_timer.start()
		
		await get_tree().create_timer(I_FRAMES_DURATION).timeout
		if active_state == State.STUN:
			change_state(State.IDLE)

func health_pickup():
	sfx_heart_pickup.play()
	health += 1
	if health > max_health:
		health = max_health
	set_health.emit(health)

func die() -> void:
	if active_state != State.DEAD:
		set_health.emit(0)
		change_state(State.DEAD)
		velocity = Vector2(0.0, -200.0)
		sfx_player_death.play()
		await player_sprite.animation_finished
		reset_room.emit()

func set_camera_boundaries(x: int, y: int) -> void:
	var tile_size: int = 16
	player_camera.limit_top = tile_size * -1
	player_camera.limit_bottom = (y + 1) * tile_size
	player_camera.limit_left = tile_size * -1
	player_camera.limit_right = (x + 1) * tile_size
	player_camera.reset_smoothing()

func _on_dash_timer_timeout() -> void:
	can_dash = true

func _on_i_frame_timer_timeout() -> void:
	is_invincible = false

func _on_sword_hit_box_area_entered(area: Area2D) -> void:
	if area is EnemyHitBox:
		area.get_parent().hit(sword_hit_box)
