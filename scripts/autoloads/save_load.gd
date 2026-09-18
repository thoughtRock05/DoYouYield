@tool
extends Node

@export var var_key: Variant = "var name"


const DEFAULT_SAVEDATA: Dictionary = {
	"var name" : 0 #int
}

var savedata: Dictionary = {}

func _ready() -> void:
	savedata = DEFAULT_SAVEDATA.duplicate(true)

@export var file_num: int = 1

func _save(new_file: int) -> void:
	if new_file < 0 or new_file > 3:
		push_error("Invalid save file slot")
		return
	file_num = new_file
	var save_location = get_save_path(file_num)
	var file = FileAccess.open_compressed(save_location, FileAccess.WRITE, FileAccess.COMPRESSION_FASTLZ)
	if file:
		file.store_var(savedata)
		file.close()
	else:
		push_error("File failed to be made")

func _load(old_file: int) -> void:
	if old_file < 0 or old_file > 3:
		push_error("Invalid save file slot")
		return
	var save_location = get_save_path(old_file)
	var file = FileAccess.open_compressed(save_location, FileAccess.READ, FileAccess.COMPRESSION_FASTLZ)
	if file:
		var temp_savedata: Dictionary = file.get_var()
		file.close()
		if temp_savedata is Dictionary:
			savedata = DEFAULT_SAVEDATA.duplicate(true)
			for key in temp_savedata:
				_set_dictionary_value(key, temp_savedata[key])
		else:
			push_error("Corrupted file")
			savedata = DEFAULT_SAVEDATA.duplicate(true)
	else:
		push_error("File failed to load")
		savedata = DEFAULT_SAVEDATA.duplicate(true)

func get_save_path(num: int) -> String:
	return "user://SaveFile" + str(num) + ".bin"

func _set_dictionary_value(key: Variant, value: Variant) -> void:
	if not multiplayer.is_server(): return
	if savedata.has(key):
		if typeof(savedata.get(key)) == typeof(value):
			savedata[key] = value
		else:
			push_error("Wrong variant assignment type")
	else:
		push_error("No such key exists")

func get_key_value(key: Variant) -> Variant:
	if savedata.has(key):
		return savedata[key]
	else:
		push_error("No such key exists")
		return null

func get_save_file() -> int:
	return file_num
