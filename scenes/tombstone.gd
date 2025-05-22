extends Node2D

@export var messages := ["Una tumba sin nombre...", "Tal vez de un héroe olvidado."]
@onready var dialog_scene = preload("res://scenes/dialog_popup.tscn")
@onready var indicator := $InteractIndicator  # Asegúrate de que este nodo exista

var player_in_range := false
var dialog_instance: CanvasLayer = null

func _ready():
	$Area2D.connect("body_entered", _on_area_2d_body_entered)
	$Area2D.connect("body_exited", _on_area_2d_body_exited)
	indicator.visible = false  # Ocultamos al inicio

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		if dialog_instance == null:
			dialog_instance = dialog_scene.instantiate()
			get_tree().get_root().add_child(dialog_instance)
			dialog_instance.set_text_array(messages)
		else:
			dialog_instance.advance_text()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("➡️ Jugador entró en el área del cartel")
		player_in_range = true
		indicator.visible = true
		indicator.play("default")  # ▶️ Reproduce la animación al entrar

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		print("⬅️ Jugador salió del área del cartel")
		player_in_range = false
		indicator.visible = false
		indicator.stop()  # ⏹️ Opcional: detener animación al salir
		if dialog_instance:
			dialog_instance.queue_free()
			dialog_instance = null
