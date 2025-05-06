extends Camera2D

@onready var cam := $Camera2D

func _ready():
	cam.current = true
	cam.smoothing_enabled = true
	cam.smoothing_speed = 5.0  # Ajusta la suavidad del seguimiento (más bajo = más lento)
	cam.zoom = Vector2(1.5, 1.5)  # Ajusta el "zoom" de la cámara (más alto = más cercano)

	# Opcional: límites para que no se mueva fuera del mapa (si tienes un mundo delimitado)
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = 5000  # cambia según tu nivel
	cam.limit_bottom = 1000
