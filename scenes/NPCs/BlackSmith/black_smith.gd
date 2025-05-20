extends CharacterBody2D

@export var dialogue_lines := [
	"¡Eh! Cuidado con esa espada... aún está caliente.",
	"¿Buscas fuerza o estilo? Porque hacer ambas cosas me cuesta el doble.",
	"Yo hago armas. Tú las usas. Es una relación sana.",
	"He visto espadas más oxidadas que tu armadura... y eso es mucho decir.",
	"Si encuentras mineral raro por ahí, tráemelo. Me aburro haciendo espadas normales.",
	"Recuerda: no importa cuán fuerte seas, sin un buen filo... solo estás dando empujones."
]

@onready var animated_sprite := $AnimatedSprite2D
@onready var area := $DetectArea
@onready var interaction_icon := $Sprite2D
@onready var dialog_scene := preload("res://scenes/dialog_popup.tscn")
@onready var upgrade_menu_scene := preload("res://scenes/NPCs/BlackSmith/black_smith_upgrade_menu.tscn")

var player_in_range := false
var dialogue_active := false
var player_ref: Node2D = null

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
			popup.name = "DialogPopup"
			get_tree().get_root().add_child(popup)
			dialogue_active = true
			popup.set_text_array(dialogue_lines)

			if player_ref:
				player_ref.set_can_move(false)

			popup.connect("tree_exited", Callable(self, "_on_dialogue_finished"))
		else:
			var popup = get_tree().get_root().get_node_or_null("DialogPopup")
			if popup:
				popup.advance_text()

func _on_detect_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true
		player_ref = body

func _on_detect_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false

func _on_dialogue_finished():
	dialogue_active = false

	var stage = get_tree().get_root().get_node_or_null("Stage1")
	if stage and stage.has_method("registrar_npc_hablado"):
		stage.registrar_npc_hablado()

	if player_ref:
		var upgrade_menu = upgrade_menu_scene.instantiate()
		upgrade_menu.player = player_ref
		get_tree().get_root().add_child(upgrade_menu)
