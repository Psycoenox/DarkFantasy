extends Node2D

@onready var mission_ui = $MissionDisplayEnemigos 
@onready var music_player = $MusicPlayer  # 👈 Asegúrate que el nodo se llame así

var total_enemigos := 0
var enemigos_derrotados := 0

func _ready():
	if not PauseMenu.get_parent():
		get_tree().get_root().add_child(PauseMenu)
		PauseMenu.visible = false  # 🔒 Comienza oculto
	if music_player and not music_player.playing:
		music_player.play()
		music_player.stream_paused = false
		print("🎶 Música iniciada")
		
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
