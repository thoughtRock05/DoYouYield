extends Node

@export var player: Player

@export var yield_prompt: Control
@export var yes_button: Button
@export var no_button: Button

@export var room_options: Control
@export var back_button: Button

@export var main_menu: StringName = &""
@export var main_menu_button: Button

@export var reset_button: Button

@export var lock: Lock

var room: String
var uid: String

@export var take_heart: bool = false
@export var taken_item: String

var can_interact: bool = true
var in_options_menu: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	player.can_move = true
	yield_prompt.visible = false
	room_options.visible = false
	lock.trigger_lock.connect(_on_lock_triggered)
	yes_button.pressed.connect(_on_yes_pressed)
	no_button.pressed.connect(_on_no_pressed)
	
	back_button.pressed.connect(_on_back_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	player.reset_room.connect(_on_reset_pressed)
	uid = ResourceUID.id_to_text(ResourceLoader.get_resource_uid(scene_file_path))

func _process(_delta: float) -> void:
	if not can_interact:
		return
	
	if Input.is_action_just_pressed("reset"):
		if not in_options_menu:
			can_interact = false
			SceneTransition.load_scene(uid)
			can_interact = true
	
	if Input.is_action_just_pressed("escape"):
		in_options_menu = not in_options_menu
		player.can_move = not in_options_menu
		get_tree().paused = in_options_menu
		room_options.visible = in_options_menu
		
		if in_options_menu:
			back_button.grab_focus()

func _on_lock_triggered(_room: String) -> void:
	player.can_move = false
	yield_prompt.visible = true
	room = _room
	get_tree().paused = true
	yes_button.grab_focus()

func _on_yes_pressed() -> void:
	can_interact = false
	if take_heart:
		SaveLoad._set_dictionary_value(SaveLoad.max_health_key, SaveLoad.get_key_value(SaveLoad.max_health_key) - 1)
	match taken_item: #TODO replace w/ actual mechanics
		"a":
			pass #SaveLoad._set_dictionary_value(SaveLoad.mechanic_key, false)
		"b":
			pass
		"c":
			pass
		"d":
			pass
		"e":
			pass
		"f":
			pass
		_:
			pass # default case
	
	get_tree().paused = false
	yield_prompt.visible = false
	SceneTransition.load_scene(room)

func _on_no_pressed() -> void:
	yield_prompt.visible = false
	get_tree().paused = false
	player.can_move = true

func _on_back_pressed() -> void:
	room_options.visible = false
	get_tree().paused = false
	player.can_move = true

func _on_main_menu_pressed() -> void:
	can_interact = false
	player.can_move = false
	get_tree().paused = false
	SceneTransition.load_scene(main_menu)

func _on_reset_pressed() -> void:
	can_interact = false
	player.can_move = false
	room_options.visible = false
	get_tree().paused = false
	SceneTransition.load_scene(uid)
