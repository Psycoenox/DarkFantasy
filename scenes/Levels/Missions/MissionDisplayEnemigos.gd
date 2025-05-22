extends "res://scenes/Levels/Missions/MissionDisplay.gd"

var total_enemigos := 0
var derrotados := 0

func activar_mision_enemigos(total: int):
	derrotados = 0
	total_enemigos = total
	mission_activa = true
	progress_label.visible = true
	progress_label.modulate.a = 1.0
	actualizar_progreso()

func enemigo_derrotado(enemy = null):
	if not mission_activa:
		return

	derrotados += 1
	actualizar_progreso()

func actualizar_progreso():
	progress_label.text = "Misión: Derrota a todos los enemigos (%d/%d)" % [derrotados, total_enemigos]

	if derrotados >= total_enemigos:
		GameManager.missions["zona_2_enemigos_derrotados"] = true
		mission_activa = false
		await get_tree().process_frame
#a		$Background.custom_minimum_size = $Background.get_child(0).get_minimum_size()
		animation_player.play("fade_out_progress")
