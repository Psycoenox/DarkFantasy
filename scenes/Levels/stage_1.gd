extends Node2D

@onready var boss = $Boss
@onready var bonfire_scene = preload("res://scenes/bonfire.tscn")
@onready var music_player = $MusicPlayer  # 👈 Asegúrate que el nodo se llame así

var npcs_hablados := 0
const NPCS_REQUERIDOS := 2

func _ready():
		# Solo si hay datos cargados
	if SaveSystem.loaded_data != {}:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var pos = SaveSystem.loaded_data.get("player_position", null)
			if pos:
				player.global_position = Vector2(pos["x"], pos["y"])  # Asegúrate de usar un Vector2

			player.health = SaveSystem.loaded_data.get("player_health", player.health)
			player.max_health = SaveSystem.loaded_data.get("player_max_health", player.max_health)
			player.coins = SaveSystem.loaded_data.get("coins", player.coins)

		# Limpiar datos para evitar reaplicación si reinicias
		SaveSystem.loaded_data = {}

	if not PauseMenu.get_parent():
		get_tree().get_root().add_child(PauseMenu)
		PauseMenu.visible = false  # 🔒 Comienza oculto
	# 🎵 Reproducir música si no está ya sonando

	if music_player and not music_player.playing:
		music_player.play()
		music_player.stream_paused = false
		print("🎶 Música iniciada")

	if boss:
		boss.connect("boss_defeated", Callable(self, "_on_boss_defeated"))
	else:
		print("❌ No se encontró el boss en la escena")

func registrar_npc_hablado():
	npcs_hablados += 1
	if npcs_hablados >= NPCS_REQUERIDOS:
		GameManager.missions["zona_1_npcs_hablados"] = true
		print("✅ Misión completada: Zona 2 desbloqueada.")

func _on_boss_defeated():
	print("🔥 El boss fue derrotado. Aparece la fogata.")
	var bonfire = bonfire_scene.instantiate()
	bonfire.global_position = boss.global_position + Vector2(0, -16)
	add_child(bonfire)
