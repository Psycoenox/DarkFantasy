extends CharacterBody2D

@export var gravity := 800.0
@export var max_fall_speed := 200.0
@export var attract_speed := 250.0
@export var amount := 1

var is_being_attracted := false
var player_node: Node2D = null

func _ready():
	$AnimatedSprite2D.play("default")
	add_to_group("coins")

func _physics_process(delta):
	if is_being_attracted and player_node:
		var direction = (player_node.global_position - global_position).normalized()
		velocity = direction * attract_speed
	else:
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.y = 0

	velocity.y = clamp(velocity.y, -max_fall_speed, max_fall_speed)
	move_and_slide()

	if is_being_attracted and global_position.distance_to(player_node.global_position) < 10:
		_collect()

func attract_to_player(player):
	is_being_attracted = true
	player_node = player

func _collect():
	if player_node and player_node.has_method("collect_coin"):
		player_node.collect_coin(amount)
	queue_free()
