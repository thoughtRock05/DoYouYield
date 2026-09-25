@tool
extends Parallax2D
class_name RoomParallax

const TILE_SIZE: float = 32.0
const VIEWPORT_WIDTH: float = 640.0
const VIEWPORT_HEIGHT: float = 360.0

@export var environment: Control

@export var room_tiles_x: int = 1:
	set(value):
		room_tiles_x = value
		queue_redraw()

@export var room_tiles_y: int = 1:
	set(value):
		room_tiles_y = value
		queue_redraw()

func _ready() -> void:
	if environment:
		environment.visible = true

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if Engine.is_editor_hint():
		var limit_left: float = TILE_SIZE * -1.0
		var limit_top: float = TILE_SIZE * -1.0
		var limit_right: float = (room_tiles_x + 1) * TILE_SIZE
		var limit_bottom: float = (room_tiles_y + 1) * TILE_SIZE
		
		var max_cam_x: float = max(limit_left, limit_right - VIEWPORT_WIDTH)
		var max_cam_y: float = max(limit_top, limit_bottom - VIEWPORT_HEIGHT)
		
		var camera_travel_x: float = max_cam_x - limit_left
		var camera_travel_y: float = max_cam_y - limit_top
		
		var required_width: float = VIEWPORT_WIDTH + (camera_travel_x * scroll_scale.x)
		var required_height: float = VIEWPORT_HEIGHT + (camera_travel_y * scroll_scale.y)
		
		var start_x: float = limit_left * scroll_scale.x
		var start_y: float = limit_top * scroll_scale.y
		
		var rect = Rect2(start_x, start_y, required_width, required_height)
		
		draw_rect(rect, Color(0.278, 0.549, 0.749, 1.0), false, 2.0, true)
		
		draw_line(Vector2(start_x + required_width / 2.0, start_y), Vector2(start_x + required_width / 2.0, start_y + required_height), Color(0.278, 0.549, 0.749, 0.3), 1.0)
		draw_line(Vector2(start_x, start_y + required_height / 2.0), Vector2(start_x + required_width, start_y + required_height / 2.0), Color(0.278, 0.549, 0.749, 0.3), 1.0)
