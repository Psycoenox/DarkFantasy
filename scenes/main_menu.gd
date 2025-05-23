extends Control

@onready var jugar_button = $VBoxContainer/Jugar
@onready var cargar_button = $VBoxContainer/Cargar
@onready var opciones_button = $VBoxContainer/Opciones
@onready var salir_button = $VBoxContainer/Salir
@onready var music_player = $MusicPlayer  # 👈 Asegúrate que el nodo se llame así
@onready var options_scene := preload("res://scenes/options_menu.tscn")  # ajusta la ruta
var options_instance: Node = null

func _ready():
	if music_player and not music_player.playing:
		music_player.play()
		music_player.stream_paused = false
		print("🎶 Música iniciada")
	# Desactiva el botón de cargar por defecto (hasta implementar el guardado)
	cargar_button.disabled = true

	# Conectar señales de los botones
	jugar_button.pressed.connect(_on_jugar_pressed)
	cargar_button.pressed.connect(_on_cargar_pressed)
	opciones_button.pressed.connect(_on_opciones_pressed)
	salir_button.pressed.connect(_on_salir_pressed)

func _on_jugar_pressed():
	get_tree().change_scene_to_file("res://scenes/Levels/stage_1.tscn")

func _on_cargar_pressed():
	print("Funcionalidad de cargar partida aún no implementada.")

func _on_opciones_pressed():
	if not options_instance:
		options_instance = options_scene.instantiate()
		add_child(options_instance)
	else:
		options_instance.visible = true

func _on_salir_pressed():
	get_tree().quit()
