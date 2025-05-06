extends CharacterBody2D

@export var gravity := 1000
@export var max_fall_speed := 500

@onready var sprite = $AnimatedSprite2D
@onready var interact_area = $InteractArea
@onready var bonfire_ui_scene = preload("res://scenes/bonfire_ui.tscn")  # Asegúrate que esta ruta sea correcta

var player_ref: Node2D = null
var bonfire_ui_instance: Node = null

func _ready():
	sprite.play("idle")
	interact_area.connect("body_entered", Callable(self, "_on_body_entered"))
	interact_area.connect("body_exited", Callable(self, "_on_body_exited"))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	velocity.y = clamp(velocity.y, -9999, max_fall_speed)
	move_and_slide()

	if player_ref and Input.is_action_just_pressed("interact"):
		enter_bonfire()


func enter_bonfire():
	if bonfire_ui_instance == null:
		bonfire_ui_instance = bonfire_ui_scene.instantiate()
		bonfire_ui_instance.name = "BonfireUI"
		get_tree().get_root().add_child(bonfire_ui_instance)

		if player_ref:
			player_ref.set_can_move(false)  # ✅ si defines esto en el Player



func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_ref = body
func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_ref = body
