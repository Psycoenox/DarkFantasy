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
@onready var label := $NinePatchRect/Label
@onready var interaction_icon := $Sprite2D
@onready var dialogue_box := $NinePatchRect

var current_line := 0
var dialogue_active := false
var player_in_range := false

func _ready() -> void:
	dialogue_box.visible = false
	interaction_icon.visible = false
	area.connect("body_entered", _on_detect_area_body_entered)
	area.connect("body_exited", _on_detect_area_body_exited)
	animated_sprite.play("idle")

func _process(delta):
	if player_in_range:
		interaction_icon.visible = true
	else:
		interaction_icon.visible = false

	if player_in_range and Input.is_action_just_pressed("interact"):
		if not dialogue_active:
			dialogue_active = true
			dialogue_box.visible = true
			label.text = dialogue_lines[current_line]
		else:
			current_line += 1
			if current_line < dialogue_lines.size():
				label.text = dialogue_lines[current_line]
			else:
				dialogue_box.visible = false
				dialogue_active = false
				current_line = 0

func _on_detect_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true

func _on_detect_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		dialogue_box.visible = false
