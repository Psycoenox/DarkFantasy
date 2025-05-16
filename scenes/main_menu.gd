extends Control

@onready var jugar_button = $VBoxContainer/Jugar
@onready var cargar_button = $VBoxContainer/Cargar
@onready var opciones_button = $VBoxContainer/Opciones
@onready var salir_button = $VBoxContainer/Salir

func _ready():
	# Desactiva el botón de cargar por defecto (hasta implementar el guardado)
	cargar_button.disabled = true

	# Conectar señales de los botones
	jugar_button.pressed.connect(_on_jugar_pressed)
	cargar_button.pressed.connect(_on_cargar_pressed)
	opciones_button.pressed.connect(_on_opciones_pressed)
	salir_button.pressed.connect(_on_salir_pressed)

func _on_jugar_pressed():
	get_tree().change_scene_to_file("res://scenes/Player/stage_1.tscn")

func _on_cargar_pressed():
	print("Funcionalidad de cargar partida aún no implementada.")

func _on_opciones_pressed():
	print("Opciones no implementadas todavía.")

func _on_salir_pressed():
	get_tree().quit()
