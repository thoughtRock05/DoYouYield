extends MenuState
class_name MenuSettings

var previous_state: String = "MenuMain"

@export var back: Button

func enter_state(msg: Dictionary = {}) -> void:
	super.enter_state(msg)
	
	if msg.has("previous_state"):
		previous_state = msg["previous_state"]
	
	if not back.pressed.is_connected(_on_back):
		back.pressed.connect(_on_back)
	
	back.grab_focus()

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("back") or Input.is_action_just_pressed("escape"):
		_on_back()

func _on_back() -> void:
	state_machine.change_state(previous_state)
