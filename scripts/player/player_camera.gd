extends Camera2D

const TARGET_WIDTH: float = 640.0
const TARGET_HEIGHT: float = 360.0
const TARGET_ASPECT: float = TARGET_WIDTH / TARGET_HEIGHT 

const BASE_ZOOM: Vector2 = Vector2(0.625, 0.625)

var LEVEL_MAX_WIDTH: float = 640.0
var LEVEL_MAX_HEIGHT: float = 360.0

func _ready() -> void:
	get_tree().get_root().size_changed.connect(_adjust_camera_zoom)
	await get_tree().process_frame
	_adjust_camera_zoom()

func _adjust_camera_zoom() -> void:
	var window_size: Vector2 = Vector2(get_viewport().get_visible_rect().size)
	var current_aspect: float = window_size.x / window_size.y
	
	if current_aspect >= TARGET_ASPECT:
		var world_view_height: float = TARGET_HEIGHT / BASE_ZOOM.y
		var desired_world_width: float = world_view_height * current_aspect
		
		if desired_world_width > LEVEL_MAX_WIDTH:
			var clamped_zoom_x: float = (TARGET_HEIGHT * current_aspect) / LEVEL_MAX_WIDTH
			zoom = Vector2(clamped_zoom_x, clamped_zoom_x)
		else:
			zoom = BASE_ZOOM
			
	else:
		var aspect_scale: float = TARGET_ASPECT / current_aspect
		var thin_zoom: Vector2 = BASE_ZOOM * aspect_scale
		
		var desired_world_height: float = TARGET_HEIGHT / thin_zoom.y
		if desired_world_height > LEVEL_MAX_HEIGHT:
			var clamped_zoom_y: float = TARGET_HEIGHT / LEVEL_MAX_HEIGHT
			zoom = Vector2(clamped_zoom_y, clamped_zoom_y)
		else:
			zoom = thin_zoom
