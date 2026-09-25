extends MenuState
class_name MenuNone

var room_num: int = -1
@export var music_controller: MusicController

func _ready() -> void:
	SignalBus.set_room_num.connect(_on_set_room_num)

func enter_state(msg: Dictionary = {}) -> void:
	super.enter_state(msg)
	get_tree().paused = false
	SpeedRunTimerGlobal.is_paused = false #CAUTION player may not move idk
	if room_num > -1:
		music_controller.switch_player(room_num)

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		state_machine.change_state("MenuPause")

func _on_set_room_num(i: int) -> void:
	room_num = i
