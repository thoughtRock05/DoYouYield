extends StateMachine
class_name MenuStateMachine

func _ready() -> void:
	for child in get_children():
		if child is State:
			child.state_machine = self 
			states[child.name] = child
			
			var menu = child.get_child(0) as Control
			if menu:
				menu.visible = false
	
	if initial_state:
		initial_state.enter_state()
		current_state = initial_state

func _process(delta: float) -> void:
	update(delta)
