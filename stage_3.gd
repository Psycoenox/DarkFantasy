extends Node2D

var has_key = false
var player_near_door = false

@onready var key_area = $key
@onready var door_area = $door/CollisionShape2D
@onready var door_sprite = $door/AnimatedSprite2D
@onready var player = $Player

func _ready():
	door_sprite.play("closed")



func _on_door_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_near_door = true


func _on_door_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_near_door = false

func _process(delta):
	if has_key and player_near_door and Input.is_action_just_pressed("interact"):
		door_sprite.play("open")
		print("Puerta abierta")
		get_tree().change_scene("res://BossRoom.tscn")  # Cambia de nivel


func _on_key_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		has_key = true
		key_area.queue_free()
		print("Llave recogida")
