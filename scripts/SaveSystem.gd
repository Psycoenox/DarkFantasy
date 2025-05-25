extends Node

var save_path := "user://save_game.json"
var loaded_data: Dictionary = {}  # ✅ AÑADE ESTO

func save_game(data: Dictionary) -> void:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
		file.close()
		print("✅ Partida guardada correctamente.")
	else:
		print("❌ Error al guardar la partida.")

func load_game() -> Dictionary:
	if FileAccess.file_exists(save_path):
		var file := FileAccess.open(save_path, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.parse_string(json_string)
		if typeof(json) == TYPE_DICTIONARY:
			print("✅ Partida cargada correctamente.")
			return json
		else:
			print("❌ Error al leer el JSON.")
	else:
		print("⚠️ No se encontró ningún archivo de guardado.")
	return {}
