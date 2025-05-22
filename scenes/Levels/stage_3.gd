extends Node2D

var has_key = false
var player_near_door = false

@onready var key_area = $key
@onready var key_sprite = $key/AnimatedSprite2D
@onready var door_area = $door/CollisionShape2D
@onready var door_sprite = $door/AnimatedSprite2D
@onready var player = $Player
@onready var mission_display = $MissionDisplay  # ← Asegúrate que existe

func _ready():
	# Animaciones iniciales
	door_sprite.play("closed")
	key_sprite.play("default")

	# Activar misión
	if mission_display and mission_display.has_method("activar_mision_llave"):
		mission_display.activar_mision_llave()

	if PlayerData.has_key_stage3:
		has_key = true
		key_area.queue_free()
		print("Llave ya había sido recogida previamente")
		
	# Configurar límites de la cámara del jugador
	if player and player.has_node("Camera2D"):
		var camera = player.get_node("Camera2D")
		camera.limit_left = 0
		camera.limit_right = 4657.5

func _on_door_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_near_door = true

func _on_door_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_near_door = false

func _process(delta):
	if has_key and player_near_door and Input.is_action_just_pressed("interact"):
		door_sprite.play("open")
		if mission_display and mission_display.has_method("notificar_puerta_abierta"):
			mission_display.notificar_puerta_abierta()
		await door_sprite.animation_finished
		get_tree().change_scene_to_file("res://scenes/Levels/stage_4.tscn")

func _on_key_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		has_key = true
		PlayerData.has_key_stage3 = true  # ✅ Guardar en variable persistente
		key_area.queue_free()
		print("Llave recogida")
