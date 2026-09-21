extends OptionButton

func _ready() -> void:
	self.item_selected.connect(_on_window_dropdown_selected)
	set_window_type()

func _on_window_dropdown_selected(i: int) -> void:
	match i:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func set_window_type():
	match DisplayServer.window_get_mode():
		DisplayServer.WINDOW_MODE_WINDOWED:
			selected = 0
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			selected = 1
