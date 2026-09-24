extends HSlider

@export var bus_name: String
var bus_index: int

func _ready() -> void:
	if bus_name == "Music":
		max_value = 0.45
		step = 0.045
	else:
		max_value = 1.0
		step = 0.1
	
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _on_value_changed(_value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(_value))
