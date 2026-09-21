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
const DASH_ATTACK_SPEED = 275.0
const WALL_DETATCH = 100.0
enum DashType {NONE, GROUND, AIR}
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

@export var state_machine: StateMachine

var can_move = true
var jump_count = 0
var health: int
var max_health: int
var can_dash: bool = true
var dash_dir: Vector2 = Vector2.RIGHT
var is_invincible: bool = false
var knock_v: Vector2 = Vector2.ZERO
var current_dash: DashType = DashType.NONE

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
	shield_hitbox.area_entered.connect(_on_shield_hitbox_area_entered)
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	i_frame_timer.timeout.connect(_on_i_frame_timer_timeout)
	player_sprite.position.x = 11.0
	sword_hit_box.position.x = 30.0
	
	state_machine.init(self)

func _physics_process(delta: float) -> void:
	if not can_move:
		return
	if is_on_floor() and dash_timer.is_stopped() and current_dash != DashType.GROUND:
		can_dash = true
		current_dash = DashType.NONE
	var dir = Input.get_axis("left","right")
	check_camera(delta)
	update_facing(dir)
	update_shield_visuals()
	move_and_slide()
	state_machine.physics_update(delta)

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
	buffer_timer.stop()
	state_machine.change_state("PlayerJump")

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

func update_facing(dir: float):
	var current_state_name = state_machine.current_state.name
	if current_state_name in ["PlayerDash", "PlayerAttack", "PlayerDead"]:
		return
	if dir != 0:
		if current_state_name == "jump" and velocity.x != 0:
			if velocity.x < 0:
				player_sprite.position.x = -8.0
				player_sprite.flip_h = true
				sword_hit_box.position.x = -30.0
			elif velocity.x > 0:
				player_sprite.position.x = 11.0
				player_sprite.flip_h = false
				sword_hit_box.position.x = 30.0
		elif dir < 0:
			player_sprite.position.x = -8.0
			player_sprite.flip_h = true
			sword_hit_box.position.x = -30.0
		elif dir > 0:
			player_sprite.position.x = 11.0
			player_sprite.flip_h = false
			sword_hit_box.position.x = 30.0

func update_shield_visuals():
	var shielding = (state_machine.current_state.name == "PlayerShield")
	var dash_attack = (state_machine.current_state.name == "PlayerAttack" and abs(velocity.x) > DASH_ATTACK_SPEED)
	
	shield_sprite.visible = shielding or dash_attack
	shield_collision.disabled = not (shielding or dash_attack)
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
	
	var current_state_name = state_machine.current_state.name
	if is_invincible or current_state_name == "PlayerShield" or current_state_name == "PlayerDead" or (current_state_name == "PlayerAttack" and abs(velocity.x) > DASH_ATTACK_SPEED):
		return
	if not sfx_player_hurt.is_playing():
		sfx_player_hurt.play()
	
	health -= 1
	set_health.emit(health)
	
	if health <= 0:
		die()
	else:
		if current_state_name == "PlayerDash":
			dash_timer.stop()
			if current_dash == DashType.GROUND:
				can_dash = true
				current_dash = DashType.NONE
		
		state_machine.change_state("PlayerStun")
		var knock_dir: float = sign(global_position.x - area.global_position.x)
		if knock_dir == 0.0:
			knock_dir = 1
		knock_v.x = knock_dir * 500.0
		velocity.y = -250.0
		
		is_invincible = true
		i_frame_timer.start()
		
		await get_tree().create_timer(I_FRAMES_DURATION).timeout
		if state_machine.current_state.name == "PlayerStun":
			state_machine.change_state("PlayerIdle")

func health_pickup():
	sfx_heart_pickup.play()
	health += 1
	if health > max_health:
		health = max_health
	set_health.emit(health)

func die() -> void:
	if state_machine.current_state.name != "PlayerDead":
		set_health.emit(0)
		state_machine.change_state("PlayerDead")
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
	if current_dash == DashType.GROUND:
		can_dash = true
		current_dash = DashType.NONE

func _on_i_frame_timer_timeout() -> void:
	is_invincible = false

func _on_sword_hit_box_area_entered(area: Area2D) -> void:
	if area is EnemyHitBox:
		area.get_parent().hit(sword_hit_box)

func check_inputs() -> bool:
	if in_menu:
		return false
	if Input.is_action_just_pressed("shield") and has_shield:
		state_machine.change_state("PlayerShield")
		return true
	elif Input.is_action_just_pressed("dash") and has_dash and can_dash:
		state_machine.change_state("PlayerDash")
		return true
	elif Input.is_action_just_pressed("attack") and has_sword:
		state_machine.change_state("PlayerAttack")
		return true
	return false

func _on_shield_hitbox_area_entered(area: Area2D) -> void:
	var current_state_name = state_machine.current_state.name
	if current_state_name == "PlayerShield":
		if area is EnemyHitBox:
			area.get_parent().hit(shield_hitbox)
