extends "res://scenes/Levels/Missions/MissionDisplay.gd"

var llave_encontrada := false

func activar_mision_llave():
	progress_label.visible = true
	progress_label.modulate.a = 1.0
	progress_label.text = "Misión: Encuentra la llave"

func notificar_llave_encontrada():
	if not llave_encontrada:
		llave_encontrada = true
		progress_label.text = "✔️ Llave encontrada. Ahora abre la puerta"

func notificar_puerta_abierta():
	progress_label.text = "✅ Puerta abierta. ¡Avanza!"
	mission_activa = false
	await get_tree().process_frame
	animation_player.play("fade_out_progress")
