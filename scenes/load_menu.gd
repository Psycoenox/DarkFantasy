extends CanvasLayer

@onready var status_label: Label = $Panel/VBoxContainer/StatusLabel
@onready var back_button = $Panel/VBoxContainer/BackButton  
@onready var load_buttons := [
	$Panel/VBoxContainer/LoadSlot1,
	$Panel/VBoxContainer/LoadSlot2,
	$Panel/VBoxContainer/LoadSlot3
]

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)

	for i in load_buttons.size():
		var path = "user://save_slot_%d.json" % (i + 1)
		if FileAccess.file_exists(path):
			var file = FileAccess.open(path, FileAccess.READ)
			var content = file.get_as_text()
			var save_data = JSON.parse_string(content)
			if typeof(save_data) == TYPE_DICTIONARY and save_data.has("stage") and save_data.has("player_health"):
				var info = save_data["stage"].get_file().get_basename()
				var hp = save_data["player_health"]
				load_buttons[i].text = "Slot %d - %s - Vida: %s" % [i + 1, info, str(hp)]
			else:
				load_buttons[i].text = "Slot %d - (Datos corruptos)" % (i + 1)
		else:
			load_buttons[i].text = "Slot %d - Vacío" % (i + 1)

		load_buttons[i].pressed.connect(func(): load_game(i + 1))


func load_game(slot: int):
	var path = "user://save_slot_%d.json" % slot
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var save_data = JSON.parse_string(content)
			if typeof(save_data) == TYPE_DICTIONARY:
				if save_data.has("stage"):
					SaveSystem.loaded_data = save_data
					var stage_path = save_data["stage"]
					status_label.text = "✅ Cargando partida del slot %d..." % slot
					await get_tree().create_timer(0.5).timeout
					get_tree().change_scene_to_file(stage_path)
				else:
					status_label.text = "⚠️ El archivo no contiene información de escena."
			else:
				status_label.text = "❌ Error al interpretar el archivo JSON."
	else:
		status_label.text = "❌ No se encontró una partida guardada en el slot %d." % slot
		
		
func _on_back_button_pressed():
	print("llendo al main menu")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
