extends Node2D

@export var message: String = "Una tumba sin nombre..."
@onready var dialog_scene = preload("res://scenes/dialog_popup.tscn")
var player_in_range := false

func _ready():
	$Area2D.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))
	$Area2D.connect("body_exited", Callable(self, "_on_area_2d_body_exited"))

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		show_dialog()

func show_dialog():
	var dialog = dialog_scene.instantiate()
	if dialog:
		if dialog.has_method("set_text"):
			dialog.set_text(message)
			get_tree().get_root().add_child(dialog)
		else:
			print("❌ El método 'set_text' no existe en la escena dialog_popup.")
	else:
		print("❌ No se pudo instanciar la escena dialog_popup.")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true
		print("➡️ El jugador se acercó a la tumba.")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		print("⬅️ El jugador se alejó de la tumba.")
 
