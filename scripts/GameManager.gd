extends Node

# Diccionario de progreso de misiones
var missions = {
	"zona_1_npcs_hablados": false,
	"zona_2_enemigos_derrotados": false,
	"zona_3_puerta_abierta": false
}

# Función para consultar si se desbloqueó una zona
func desbloquear_zona(zona: String) -> bool:
	match zona:
		"1": return true  # Siempre disponible
		"2": return missions["zona_1_npcs_hablados"]
		"3": return missions["zona_2_enemigos_derrotados"]
		"4": return missions["zona_3_puerta_abierta"]
	return false

# 🔁 Manejo global del menú de pausa y reinicio
func _input(event):
	if event.is_action_pressed("pause_menu"):
		if PauseMenu:
			PauseMenu.toggle()

	if event.is_action_pressed("restart_level") and get_tree().paused:
		get_tree().paused = false
		get_tree().reload_current_scene()
