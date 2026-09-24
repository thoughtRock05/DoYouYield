@tool
extends Area2D
class_name AcidPit

@export var sfx_acid_bubble_pop: AudioStreamPlayer2D
@export var collision_shape_2d: CollisionShape2D
@export var point_light_2d: PointLight2D
@export var acid_cooldown: Timer

@export_range(1, 100, 1) var x_size: int = 1:
	set(value):
		x_size = value
		_update_shape_size()

@export_range(1, 100, 1) var y_size: int = 1:
	set(value):
		y_size = value
		_update_shape_size()

func _ready() -> void:
	if collision_shape_2d and collision_shape_2d.shape:
		collision_shape_2d.shape = collision_shape_2d.shape.duplicate()
	_update_shape_size()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED and Engine.is_editor_hint():
		var snapped_pos = global_position.snapped(Vector2(32, 32))
		if global_position != snapped_pos:
			set_notify_transform(false)
			global_position = snapped_pos
			set_notify_transform(true)

func _update_shape_size() -> void:
	if not collision_shape_2d or not point_light_2d:
		return
	
	if not is_inside_tree():
		return
	
	var width: int = x_size * 32
	var height: int = y_size * 32 + 4
	
	collision_shape_2d.shape.size = Vector2(width, height)
	
	var offset_x = 0.0
	if x_size % 2 != 0:
		offset_x = 16.0
	
	var offset_y = (height / 2.0) - 10.0
	
	collision_shape_2d.position = Vector2(offset_x, offset_y)
	point_light_2d.position = Vector2(offset_x, offset_y)
	
	point_light_2d.scale = Vector2(0.5 * x_size, (0.5 * y_size) + 0.25)
	
	if Engine.is_editor_hint():
		update_configuration_warnings()
		notify_property_list_changed()

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		if not acid_cooldown.is_stopped():
			return
			
		if randf_range(1, 100) < 30:
			if sfx_acid_bubble_pop and not sfx_acid_bubble_pop.playing: 
				sfx_acid_bubble_pop.play()
		
		acid_cooldown.start()
