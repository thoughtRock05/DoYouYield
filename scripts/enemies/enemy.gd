extends CharacterBody2D
class_name Enemy

@warning_ignore("unused_signal") signal spawn_on_death(pos: Vector2, item: PackedScene, chance: int)
@export var item : PackedScene = preload("uid://cvvxfxr3biyta")

@export var sprite: AnimatedSprite2D
@export var hitbox: Area2D
@export var sfx_damage: AudioStreamPlayer
@export var sfx_aggro: AudioStreamPlayer
@export var sfx_death: AudioStreamPlayer
@export var sfx_bonk: AudioStreamPlayer

@export var state_machine: StateMachine
@export var stun_timer: Timer

@export_group("Enemy Tuning")
@export var SPEED = 60.0:
	set(value):
		SPEED = value / self.scale.x
@export var KNOCKBACK: Vector2 = Vector2(300, 100)
@export var target: Player = null
@export var max_threshold: float = 1800.0
@export var target_threshold: float = 300.0
@export var dir: float = -1.0
@export var is_alerting: bool = false
@export var is_alerted: bool = false
@export var health: int = 3
@export var is_stunned: bool = false
@export var knock: float = 0.0
@export var drop_chance: int = 101
func _ready() -> void:
	if state_machine:
		state_machine.init(self)

func set_target(t: Player) -> void:
	target = t

func _physics_process(delta: float) -> void:
	if state_machine:
		state_machine.physics_update(delta)

func hit(area: Area2D) -> void:
	if is_stunned:
		return
	sfx_bonk.play()
	if area is SwordHitBox:
		sfx_damage.play()
		health -= 1
		if health <= 0:
			if state_machine:
				state_machine.change_state("EnemyDead")
			else:
				queue_free()
			return
	is_stunned = true
	if state_machine:
		state_machine.change_state("EnemyStunned")
	stun_timer.start()
	var knockback_dir: float = 1.0
	if area and area.owner:
		knockback_dir = sign(global_position.x - area.global_position.x)
	elif target:
		knockback_dir = sign(global_position.x - target.global_position.x)
	if knockback_dir == 0.0:
		knockback_dir = 1.0
	knock = knockback_dir * KNOCKBACK.x * (1 + int(area is ShieldHitBox))
	velocity.y -= KNOCKBACK.y
	velocity.x = knock
	await stun_timer.timeout
	is_stunned = false
