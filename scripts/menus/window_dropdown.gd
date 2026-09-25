extends OptionButton
const FONT = preload("uid://di30hy6qprkyp")

func _ready() -> void:
	self.item_selected.connect(_on_window_dropdown_selected)
	set_window_type()
	theme = Theme.new()
	theme.default_font = FONT

func _on_window_dropdown_selected(i: int) -> void:
	match i:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func set_window_type():
	match DisplayServer.window_get_mode():
		DisplayServer.WINDOW_MODE_WINDOWED:
			selected = 0
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			match get_window().borderless:
				false:
					selected = 1
				true:
					selected = 2
