extends OptionButton
class_name ResolutionDropdown

const FONT = preload("uid://di30hy6qprkyp")

func _ready() -> void:
	self.item_selected.connect(_on_resolution_dropdown_selected)
	set_resolution_type()
	theme = Theme.new()
	theme.default_font = FONT

func _on_resolution_dropdown_selected(i: int) -> void:
	match i:
		0:
			DisplayServer.window_set_size(Vector2i(640, 320))
		1:
			DisplayServer.window_set_size(Vector2i(1280, 720))
		2:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		3:
			DisplayServer.window_set_size(Vector2i(2560, 1600))
		4:
			DisplayServer.window_set_size(Vector2i(2560, 1600))

func set_resolution_type():
	match DisplayServer.window_get_size():
		Vector2i(640, 320):
			selected = 0
		Vector2i(1280, 720):
			selected = 1
		Vector2i(1920, 1080):
			selected = 2
		Vector2i(2560, 1600):
			selected = 3
		Vector2i(2560, 1600):
			selected = 4
