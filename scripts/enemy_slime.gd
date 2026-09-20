extends CharacterBody2D
class_name Slime

signal spawn_heart(pos: Vector2)

@export var sprite: AnimatedSprite2D
@export var alert: Sprite2D
@export var hitbox: Area2D
@export var sfx_slime_damage: AudioStreamPlayer
@export var sfx_slime_aggro: AudioStreamPlayer

const SPEED = 30.0
var speed = SPEED / self.scale.x
const KNOCKBACK: float = 300.0
var target: Player = null
var max_threshold: float = 900.0
var target_threshold: float = 150.0
var dir: float = -1.0
var is_alerting: bool = false
var is_alerted: bool = false
var health: int = 3
var is_stunned: bool = false
var knock: float = 0.0

func _ready() -> void:
	hitbox.area_entered.connect(hit)

func set_target(t: Player) -> void:
	target = t

func _physics_process(delta: float) -> void:
	alert.visible = is_alerting
	
	if not is_on_floor():
		velocity.y += 980.0 * delta
	
	if is_stunned:
		knock = move_toward(knock, 0.0, 1500.0 * delta)
		velocity.x = knock
	else:
		if (target.position - position).length() > max_threshold:
			return
		if (target.position - position).length() < target_threshold:
			if not is_alerted:
				sfx_slime_aggro.play()
				is_alerting = true
				is_alerted = true
				get_tree().create_timer(0.5).timeout.connect(func():
					is_alerting = false
				)
			if abs(global_position.x - target.position.x) > 0.2:
				dir = sign(target.position.x - position.x)
				velocity.x = dir * speed
			else:
				velocity.x = 0
		else:
			is_alerted = false
			if is_on_wall():
				dir = get_wall_normal().x
			velocity.x = dir * speed
		
	if abs(global_position.x - target.position.x) > 0.2:
		if velocity.x >= 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	
	if velocity.x != 0:
		sprite.play()
	
	move_and_slide()

func hit(area: Area2D) -> void:
	if is_stunned:
		return
	if area is SwordHitBox:
		sfx_slime_damage.play()
		health -= 1
		if health <= 0:
			spawn_heart.emit(position)
			self.visible = false
			self.collision_layer = 0
			self.collision_mask = 0
			await sfx_slime_damage.finished
			queue_free()
			return
	is_stunned = true
	get_tree().create_timer(0.5).timeout.connect(func():
		is_stunned = false
		)
	var knockback_dir: float = sign(global_position.x - area.global_position.x)
	if knockback_dir == 0.0:
		knockback_dir = 1.0
	knock = knockback_dir * KNOCKBACK
	velocity.y -= 100.0
	velocity.x = knock
	
