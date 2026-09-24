extends Room

@export var moving_platform_3: Node2D

func _ready() -> void:
	super._ready()
	door.set_active(false)
	moving_platform_3.process_mode = Node.PROCESS_MODE_DISABLED

func spawn_heart(pos: Vector2) -> void:
	super.spawn_heart(pos)
	door.set_active(true)
	moving_platform_3.process_mode = Node.PROCESS_MODE_PAUSABLE
