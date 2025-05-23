extends Node2D
@onready var music_player = $MusicPlayer  # 👈 Asegúrate que el nodo se llame así

func _ready():
	if not PauseMenu.get_parent():
		get_tree().get_root().add_child(PauseMenu)
		PauseMenu.visible = false  # 🔒 Comienza oculto
		
	if music_player and not music_player.playing:
		music_player.play()
		music_player.stream_paused = false
		print("🎶 Música iniciada")
	var player = get_node("Player")  # Asegúrate de que esta ruta sea correcta
	var camera = player.get_node("Camera2D")

	camera.limit_left = 0
	camera.limit_right = 1146
