extends Node

const HEART_DROP = preload("uid://cvvxfxr3biyta")

@export var player: Player

@export var room_num: int = -1

@export var heart_bar: Node2D

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

@export var tiles_x: int = 0
@export var tiles_y: int = 0

var can_interact: bool = true
var in_options_menu: bool = false

func _ready() -> void:
	Music.switch_player(room_num)
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	player.can_move = true
	yield_prompt.visible = false
	room_options.visible = false
	lock.trigger_lock.connect(_on_lock_triggered)
	yes_button.pressed.connect(_on_yes_pressed)
	no_button.pressed.connect(_on_no_pressed)
	
	player.set_camera_boundaries(tiles_x, tiles_y)
	
	back_button.pressed.connect(_on_back_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	player.reset_room.connect(_on_reset_pressed)
	uid = ResourceUID.id_to_text(ResourceLoader.get_resource_uid(scene_file_path))
	
	player.set_health.connect(heart_bar.set_health)
	player.set_max_health.connect(heart_bar.set_max_health)
	
	heart_bar.set_health(player.health)
	heart_bar.set_max_health(player.max_health)
	lock.is_open = false

	for child in get_children():
		if child is Slime:
			child.spawn_heart.connect(_on_spawn_heart)

	for child in get_children(true):
		if child is Slime:
			child.set_target(player)

func _process(_delta: float) -> void:
	if not can_interact:
		return
	
	if Input.is_action_just_pressed("reset"):
		if not in_options_menu:
			can_interact = false
			SceneTransition.load_scene(uid)
			can_interact = true
	
	if Input.is_action_just_pressed("escape"):
		if can_interact == false:
			return
		open_menu()
		
	if Input.is_action_just_pressed("back"):
		if in_options_menu == false:
			return
		if can_interact == false:
			return
		open_menu()

func open_menu() -> void:
	in_options_menu = not in_options_menu
	heart_bar.visible = not in_options_menu
	
	
	
	get_tree().paused = in_options_menu
	room_options.visible = in_options_menu
	
	if in_options_menu:
		back_button.grab_focus()
		Music.switch_player(7)
	else:
		Music.switch_player(room_num)
	
	await get_tree().create_timer(0.25).timeout
	player.can_move = not in_options_menu
	player.in_menu = in_options_menu

func _on_lock_triggered(_room: String) -> void:
	lock.is_open = true
	Music.switch_player(room_num + 8)
	can_interact = false
	player.can_move = false
	player.in_menu = true
	yield_prompt.visible = true
	room = _room
	get_tree().paused = true
	yes_button.grab_focus()

func _on_yes_pressed() -> void:
	can_interact = false
	if take_heart:
		SaveLoad._set_dictionary_value(SaveLoad.max_health_key, SaveLoad.get_key_value(SaveLoad.max_health_key) - 1)
	match taken_item:
		"double jump":
			SaveLoad._set_dictionary_value(SaveLoad.double_jump_key, false)
		"wall jump":
			SaveLoad._set_dictionary_value(SaveLoad.wall_jump_key, false)
		"sword":
			SaveLoad._set_dictionary_value(SaveLoad.sword_key, false)
		"shield":
			SaveLoad._set_dictionary_value(SaveLoad.shield_key, false)
		"dash":
			SaveLoad._set_dictionary_value(SaveLoad.dash_key, false)
		_:
			pass # default case
	
	get_tree().paused = false
	yield_prompt.visible = false
	SceneTransition.load_scene(room)

func _on_no_pressed() -> void:
	lock.is_open = false
	Music.switch_player(room_num)
	yield_prompt.visible = false
	get_tree().paused = false
	player.can_move = true
	can_interact = true

func _on_back_pressed() -> void:
	open_menu()

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

func _on_spawn_heart(pos: Vector2) -> void:
	call_deferred("spawn_heart", pos)

func spawn_heart(pos: Vector2) -> void:
	if randi_range(0,100) < 65:
		var heart = HEART_DROP.instantiate() as RigidBody2D
		add_child(heart)
		heart.position = pos
		var force = Vector2(randf_range(150,250), randf_range(150,250))
		heart.apply_force(force)
