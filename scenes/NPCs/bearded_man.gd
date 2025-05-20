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
@onready var interaction_icon := $Sprite2D
@onready var dialog_scene = preload("res://scenes/dialog_popup.tscn")  # Ajusta si está en otra ruta

var player_in_range := false
var dialogue_active := false

func _ready() -> void:
	interaction_icon.visible = false
	area.connect("body_entered", _on_detect_area_body_entered)
	area.connect("body_exited", _on_detect_area_body_exited)
	animated_sprite.play("idle")

func _process(_delta):
	interaction_icon.visible = player_in_range

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

	var stage = get_tree().get_root().get_node_or_null("Stage1")
	if stage and stage.has_method("registrar_npc_hablado"):
		stage.registrar_npc_hablado()
