extends CharacterBody2D

@export var dialogue_lines := [
	"¡Eh, joven! No es habitual ver caras nuevas por aquí...",
	"Si vas a internarte en el bosque, más te vale ir bien preparado.",
	"Dicen que criaturas extrañas han empezado a merodear por las tumbas...",
	"Yo ya soy viejo para aventuras, pero tú aún puedes hacer algo útil.",
	"Ve con cuidado. Y si encuentras algo raro, vuelve y dímelo."
]

@onready var animated_sprite := $AnimatedSprite2D
@onready var area := $DetectArea
@onready var dialog_scene = preload("res://scenes/dialog_popup.tscn")

var player_in_range := false
var dialogue_active := false
var npc_contado := false  # ✅ Para evitar múltiples registros

func _ready() -> void:
	area.connect("body_entered", _on_detect_area_body_entered)
	area.connect("body_exited", _on_detect_area_body_exited)
	animated_sprite.play("idle")

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		if not dialogue_active:
			var popup = dialog_scene.instantiate()
			get_tree().get_root().add_child(popup)
			dialogue_active = true
			popup.set_text_array(dialogue_lines)
			popup.connect("tree_exited", Callable(self, "_on_dialogue_finished"))
		else:
			var popup = get_tree().get_root().get_node_or_null("DialogPopup")
			if popup:
				popup.advance_text()

func _on_detect_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true

func _on_detect_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false

func _on_dialogue_finished():
	dialogue_active = false

	if npc_contado:
		return  # 🛑 Ya fue contado, no hacer nada

	npc_contado = true  # ✅ Marcar como registrado

	var current_scene = get_tree().get_current_scene()
	var mission_ui = current_scene.get_node_or_null("MissionDisplay")

	if current_scene and current_scene.has_method("registrar_npc_hablado"):
		current_scene.registrar_npc_hablado()

	if mission_ui and mission_ui.has_method("registrar_npc"):
		mission_ui.registrar_npc()
