extends Node2D

@onready var mission_ui = $MissionDisplayEnemigos  # Asegúrate que ese sea el nombre del nodo
var total_enemigos := 0
var enemigos_derrotados := 0

func _ready():
	var enemigos = get_tree().get_nodes_in_group("enemy")
	total_enemigos = enemigos.size()
	enemigos_derrotados = 0
	
	if mission_ui:
		mission_ui.activar_mision_enemigos(total_enemigos)

func registrar_enemigo_derrotado():
	enemigos_derrotados += 1
	if mission_ui:
		mission_ui.enemigo_derrotado()

	if enemigos_derrotados >= total_enemigos:
		GameManager.missions["zona_2_enemigos_derrotados"] = true
		print("✅ Misión completada: Enemigos derrotados")
