extends Node2D

@export var coin_scene: PackedScene
@export var potion_scene: PackedScene

@onready var sprite := $AnimatedSprite2D
@onready var area := $Area2D

var is_open := false
var player_in_range := false

func _ready():
	area.connect("body_entered", _on_area_entered)
	area.connect("body_exited", _on_area_exited)
	sprite.play("idle")  # Asegúrate de tener una animación "idle" y "open"

func _process(_delta):
	if player_in_range and not is_open and Input.is_action_just_pressed("interact"):
		open_chest()

func _on_area_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_area_exited(body):
	if body.name == "Player":
		player_in_range = false

func open_chest():
	is_open = true
	sprite.play("open")

	# 🔊 Reproducir sonido
	if has_node("OpenChest"):
		$OpenChest.play()

	await sprite.animation_finished

	spawn_loot()


func spawn_loot():
	var coin_count = randi_range(1, 10)
	var potion_count = randi_range(1, 2)

	for i in coin_count:
		var coin = coin_scene.instantiate()
		get_tree().current_scene.add_child(coin)
		coin.global_position = global_position + Vector2(randf_range(-16, 16), -8)

	for i in potion_count:
		var potion = potion_scene.instantiate()
		get_tree().current_scene.add_child(potion)
		potion.global_position = global_position + Vector2(randf_range(-16, 16), -8)
