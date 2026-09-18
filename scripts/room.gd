extends Node

@export var yield_prompt: Control
@export var yes_button: Button
@export var no_button: Button

@export var lock: Lock

var room: String
var uid: String

func _ready() -> void:
	yield_prompt.visible = false
	lock.trigger_lock.connect(_on_lock_triggered)
	yes_button.pressed.connect(_on_yes_pressed)
	no_button.pressed.connect(_on_no_pressed)
	
	uid = ResourceUID.id_to_text(ResourceLoader.get_resource_uid(scene_file_path))

func _on_lock_triggered(_room: String) -> void:
	yield_prompt.visible = true
	room = _room
	get_tree().paused = true
	yes_button.grab_focus()

func _on_yes_pressed() -> void:
	get_tree().paused = false
	yield_prompt.visible = false
	SceneTransition.load_scene(room)

func _on_no_pressed() -> void:
	yield_prompt.visible = false
	get_tree().paused = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		SceneTransition.load_scene(uid)
