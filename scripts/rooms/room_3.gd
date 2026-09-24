extends Room

@export var moving_platform_3: Node2D

func _ready() -> void:
	super._ready()
	door.set_active(false)
	moving_platform_3.process_mode = Node.PROCESS_MODE_DISABLED

func spawn_item(pos: Vector2, _item: PackedScene, chance: int) -> void:
	super.spawn_item(pos, _item, chance)
	door.set_active(true)
	moving_platform_3.process_mode = Node.PROCESS_MODE_PAUSABLE
