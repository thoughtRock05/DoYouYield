extends CheckButton

func _ready() -> void:
	self.toggled.connect(_on_toggle)
	set_toggle()

func _on_toggle(b: bool) -> void:
	SpeedRunTimerGlobal.is_speedrunning = b

func set_toggle() -> void:
	button_pressed = SpeedRunTimerGlobal.is_speedrunning
