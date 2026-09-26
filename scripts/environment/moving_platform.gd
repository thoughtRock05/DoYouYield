@tool
extends Node2D
class_name MovingPlatform

@export var animatable_body_2d: AnimatableBody2D
@export var collision_shape_2d: CollisionShape2D
@export var tile_map_layer: TileMapLayer
@export_group("Tile Atlases")
@export var source_id: int = 1
@export var top_tile: Vector2i = Vector2i(1, 0)
@export var top_left_tile: Vector2i = Vector2i(2, 0)
@export var left_tile: Vector2i = Vector2i(8, 0)
@export var top_right_tile: Vector2i = Vector2i(3, 0)
@export var right_tile: Vector2i = Vector2i(4, 0)
@export var center_tile: Vector2i = Vector2i(0, 0)
@export var bottom_left_tile: Vector2i = Vector2i(7, 0)
@export var bottom_right_tile: Vector2i = Vector2i(5, 0)
@export var bottom_tile: Vector2i = Vector2i(6, 0)
@export var left_edge_tile: Vector2i = Vector2i(9, 0)
@export var right_edge_tile: Vector2i = Vector2i(11, 0)
@export var middle_edge_tile: Vector2i = Vector2i(10, 0)

@export_category("Size & Position")
@export_range(1, 100, 1) var x_size: int = 1:
	set(value):
		x_size = value
		if is_node_ready():
			update_shape_size()
			update_visuals()

@export_range(1, 100, 1) var y_size: int = 1:
	set(value):
		y_size = value
		if is_node_ready():
			update_shape_size()
			update_visuals()

@export_range(-20.0, 20.0, 1.0) var rel_x: float = 0.0:
	set(value):
		rel_x = value
		if is_node_ready():
			end_pos = start_pos + Vector2(rel_x * 32, rel_y * 32)
			start_tween()
		queue_redraw()

@export_range(-20.0, 20.0, 1.0) var rel_y: float = 0.0:
	set(value):
		rel_y = value
		if is_node_ready():
			end_pos = start_pos + Vector2(rel_x * 32, rel_y * 32)
			start_tween()
		queue_redraw()

@export_range(0.5, 10.0, 1.0) var duration: float = 1.0:
	set(value):
		duration = value
		if is_node_ready():
			end_pos = start_pos + Vector2(rel_x * 32, rel_y * 32)
			start_tween()
		queue_redraw()

var tween: Tween

var start_pos: Vector2
var end_pos: Vector2

func _ready() -> void:
	set_notify_transform(true)
	
	if collision_shape_2d and collision_shape_2d.shape:
		collision_shape_2d.shape = collision_shape_2d.shape.duplicate()
	
	start_pos = Vector2.ZERO
	end_pos = start_pos + Vector2(rel_x * 32, rel_y * 32)
	update_shape_size()
	start_tween()

func start_tween() -> void:
	if tween and tween.is_valid():
		tween.kill()
	
	end_pos = start_pos + Vector2(rel_x * 32, rel_y * 32)
	tween = create_tween().set_loops()
	tween.tween_property(animatable_body_2d, "position", end_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(animatable_body_2d, "position", start_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED and Engine.is_editor_hint():
		var snapped_pos = global_position.snapped(Vector2(32, 32))
		if global_position != snapped_pos:
			set_notify_transform(false)
			global_position = snapped_pos
			set_notify_transform(true)
			queue_redraw()

func update_visuals() -> void:
	if not tile_map_layer or not is_inside_tree():
		return
	tile_map_layer.clear()
	
	for x in range(x_size):
		for y in range(y_size):
			var coords = Vector2i(x, y)
			var chosen_tile = center_tile
			
			if y_size == 1:
				if x == 0:
					chosen_tile = left_edge_tile
				elif x == x_size - 1:
					chosen_tile = right_edge_tile
				else:
					chosen_tile = middle_edge_tile
			else:
				if y == 0:
					if x == 0:
						chosen_tile = top_left_tile
					elif x == x_size - 1:
						chosen_tile = top_right_tile
					else:
						chosen_tile = top_tile
				elif y == y_size - 1:
					if x == 0:
						chosen_tile = bottom_left_tile
					elif x == x_size - 1:
						chosen_tile = bottom_right_tile
					else:
						chosen_tile = bottom_tile
				elif x == 0:
					chosen_tile = left_tile
				elif x == x_size - 1:
					chosen_tile = right_tile
				
			tile_map_layer.set_cell(coords, source_id, chosen_tile)

func update_shape_size() -> void:
	if not collision_shape_2d or not is_inside_tree():
		return
		
	var width: int = x_size * 32
	var height: int = y_size * 32
	
	if collision_shape_2d.shape:
		collision_shape_2d.shape.size = Vector2(width, height)
		
	collision_shape_2d.position = Vector2(width / 2.0, height / 2.0)
	
	update_visuals()
	
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _draw() -> void:
	if Engine.is_editor_hint():
		var current_start = Vector2.ZERO
		var current_end = Vector2(rel_x * 32, rel_y * 32)
		
		draw_dashed_line(current_start, current_end, Color(0.278, 0.549, 0.749, 1.0), 2.0, 5.0)
		draw_circle(current_end, 10.0, Color(0.278, 0.549, 0.749, 1.0))
