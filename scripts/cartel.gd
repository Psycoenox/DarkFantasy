extends Node2D

@export var messages := ["Una tumba sin nombre...", "Tal vez de un héroe olvidado."]
@onready var dialog_scene = preload("res://scenes/dialog_popup.tscn")
@onready var indicator := $InteractIndicator  # Asegúrate de que este nodo exista

var player_in_range := false
var dialog_instance: CanvasLayer = null

func _ready():
	print("🟢 Cartel cargado correctamente")
	$Area2D.connect("body_entered", _on_area_2d_body_entered)
	$Area2D.connect("body_exited", _on_area_2d_body_exited)
	indicator.visible = false  # Oculta el ícono al inicio

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		print("🟡 El jugador ha presionado E")

		if dialog_instance == null:
			dialog_instance = dialog_scene.instantiate()
			get_tree().get_root().add_child(dialog_instance)
			dialog_instance.set_text_array(messages)
			dialog_instance.connect("tree_exited", Callable(self, "_on_dialogue_finished"))
		else:
			dialog_instance.advance_text()

func _on_dialogue_finished():
	if dialog_instance:
		dialog_instance.queue_free()
		dialog_instance = null

	var stage = get_tree().get_current_scene()
	var mission_ui = stage.get_node_or_null("MissionDisplay")
	if mission_ui:
		mission_ui.activar_mision(2)
		print("✅ Misión activada desde el cartel")
	else:
		print("❌ MissionUI no encontrado")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("➡️ Jugador entró en el área del cartel")
		player_in_range = true
		indicator.visible = true  # Mostrar ícono

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		print("⬅️ Jugador salió del área del cartel")
		player_in_range = false
		indicator.visible = false  # Ocultar ícono
		if dialog_instance:
			dialog_instance.queue_free()
			dialog_instance = null
