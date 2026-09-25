extends MenuState
class_name MenuNone

func enter_state(msg: Dictionary = {}) -> void:
	super.enter_state(msg)
	get_tree().paused = false
	SpeedRunTimerGlobal.is_paused = false #CAUTION player may not move idk

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		state_machine.change_state("MenuPause")
