extends Node2D

@export var messages := ["Una tumba sin nombre...", "Tal vez de un héroe olvidado."]
@onready var dialog_scene = preload("res://scenes/dialog_popup.tscn")

var player_in_range := false
var dialog_instance: CanvasLayer = null

func _ready():
	$Area2D.connect("body_entered", _on_area_2d_body_entered)
	$Area2D.connect("body_exited", _on_area_2d_body_exited)

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
		player_in_range = true
		print("➡️ El jugador se acercó al cartel o tumba.")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		print("⬅️ El jugador se alejó.")
		if dialog_instance:
			dialog_instance.queue_free()
			dialog_instance = null
