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
