extends Node2D

func _ready():
	var player = get_node("Player")  # Asegúrate de que esta ruta sea correcta
	var camera = player.get_node("Camera2D")

	camera.limit_left = 0
	camera.limit_right = 1146
