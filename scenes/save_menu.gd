extends CanvasLayer

signal cerrar_menu_guardado

@onready var slot_buttons := [
	$Panel/VBoxContainer/Slot1,
	$Panel/VBoxContainer/Slot2,
	$Panel/VBoxContainer/Slot3
]
@onready var cancel_btn = $Panel/VBoxContainer/CancelButton
@onready var confirmacion_label: Label = $Panel/VBoxContainer/Confirmacion  # 🔹 Añadido

func _ready():
	for i in slot_buttons.size():
		var path = "user://save_slot_%d.json" % (i + 1)
		if FileAccess.file_exists(path):
			var file = FileAccess.open(path, FileAccess.READ)
			var content = file.get_as_text()
			var save_data = JSON.parse_string(content)
			if typeof(save_data) == TYPE_DICTIONARY:
				var scene = save_data.get("stage", "??").get_file().get_basename()
				var hp = save_data.get("player_health", "?")
				var coins = save_data.get("coins", "?")
				var missions = save_data.get("missions", {})
				var boss_done = missions.get("boss1_defeated", false)

				var info = "Slot %d - %s - Vida: %s - 🪙 %s" % [i + 1, scene, str(hp), str(coins)]
				if boss_done:
					info += " - 🧠 Jefe derrotado"
				slot_buttons[i].text = info
			else:
				slot_buttons[i].text = "Slot %d - (Datos corruptos)" % (i + 1)
		else:
			slot_buttons[i].text = "Slot %d - Vacío" % (i + 1)

		var slot_index := i
		slot_buttons[i].pressed.connect(func():
			print("➡️ Botón slot %d presionado" % (slot_index + 1))
			save_to_slot(slot_index + 1)
		)

	cancel_btn.pressed.connect(_on_cancel)

func save_to_slot(slot: int) -> void:
	print("➡️ Guardando en slot ", slot)
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("❌ No se encontró al jugador.")
		return

	var data := {
		"stage": get_tree().current_scene.scene_file_path,
		"player_position": {
			"x": player.global_position.x,
			"y": player.global_position.y
		},
		"player_health": player.health,
		"player_max_health": player.max_health,
		"coins": player.coins
	}

	print("📦 Datos listos")

	var path = "user://save_slot_%d.json" % slot
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
		print("✅ Guardado en slot %d" % slot)
	else:
		print("❌ Error al guardar en slot %d" % slot)

	show_confirmation("✅ Guardado con éxito")
	get_tree().paused = false
	print("✅ Todo listo después del guardado")

func show_confirmation(text: String) -> void:
	confirmacion_label.text = text
	confirmacion_label.visible = true
	await get_tree().create_timer(2.0).timeout
	confirmacion_label.visible = false

func _on_cancel():
	emit_signal("cerrar_menu_guardado")
	queue_free()
