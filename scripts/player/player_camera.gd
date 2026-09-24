extends Camera2D

@export var target: Player
@export var lead_distance: float = 15.0
@export var smooth_speed: float = 4.0

func _physics_process(delta: float) -> void:
	if not target:
		return
	var move_direction = target.velocity.normalized()
	var target_pos = target.global_position + (move_direction * lead_distance)
	global_position = global_position.lerp(target_pos, smooth_speed * delta)
