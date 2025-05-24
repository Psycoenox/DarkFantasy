extends CharacterBody2D

@export var speed := 50
@export var gravity := 800
@export var max_fall_speed := 400
@export var patrol_points: Array[Vector2] = []
@export var attack_range := 80.0
@export var attack_cooldown := 8.0
@export var health := 160
@export var damage := 30
@export var coin_scene: PackedScene
@export var attack_area_offset := Vector2(40, 0)  # <- posición base del área de ataque

var is_dead := false
var patrol_index := 0
var player: Node2D = null
var state := "patrol"
var can_attack := true
var attack_animations := ["attack_1", "attack_2"]
var pending_attack := false

var frame_damage_data = {
	"attack_1": [3, 4, 5],
	"attack_2": [4, 5, 6]
}
var damaged_in_frame := {}

@onready var sprite := $Animation
@onready var area := $Area2D
@onready var attack_timer := $AttackTimer
@onready var attack_area := $AttackArea

func _ready():
	add_to_group("enemy")
	randomize()
	area.connect("body_entered", _on_area_2d_body_entered)
	area.connect("body_exited", _on_area_2d_body_exited)
	attack_timer.connect("timeout", _on_attack_timer_timeout)
	sprite.connect("animation_finished", _on_animation_animation_finished)
	attack_area.monitoring = true
	sprite.play("idle")
	update_attack_area_direction()  # aplicar dirección desde el inicio

func _physics_process(delta):
	# print("Vida actual: ", health)

	if state == "dead":
		velocity.y += gravity * delta
		velocity.y = clamp(velocity.y, -9999, max_fall_speed)
		move_and_slide()
		return

	velocity.y += gravity * delta
	velocity.y = clamp(velocity.y, -9999, max_fall_speed)

	match state:
		"patrol":
			patrol_behavior()
		"chase":
			chase_behavior()
		"attacking":
			velocity.x = 0

	move_and_slide()

func _process(_delta):
	if state == "attacking":
		var anim = sprite.animation
		var current_frame = sprite.frame

		if frame_damage_data.has(anim):
			if current_frame in frame_damage_data[anim] and not damaged_in_frame.get(current_frame, false):
				for body in attack_area.get_overlapping_bodies():
					if body.name == "Player" and body.has_method("take_damage"):
						body.take_damage(damage)
						damaged_in_frame[current_frame] = true
						print("💥 Daño aplicado en frame:", current_frame)

func patrol_behavior():
	if is_dead:
		return
	if patrol_points.is_empty():
		velocity.x = 0
		sprite.play("idle")
		return

	var target = patrol_points[patrol_index]
	var direction = (target - global_position).normalized()
	velocity.x = direction.x * speed
	sprite.flip_h = velocity.x < 0
	update_attack_area_direction()

	if sprite.animation != "run":
		sprite.play("run")

	if global_position.distance_to(target) < 5:
		patrol_index = (patrol_index + 1) % patrol_points.size()

func chase_behavior():
	if is_dead or not player:
		state = "patrol"
		return
	if not player:
		state = "patrol"
		return

	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * speed
	sprite.flip_h = direction.x < 0
	update_attack_area_direction()

	if attack_area.get_overlapping_bodies().has(player):
		if can_attack:
			attack()
		else:
			velocity.x = 0
			sprite.play("idle")
	else:
		if sprite.animation != "run":
			sprite.play("run")

func update_attack_area_direction():
	var offset = attack_area_offset
	offset.x = -abs(offset.x) if sprite.flip_h else abs(offset.x)
	attack_area.position = offset

func attack():
	if state == "dead":
		return

	var distance = global_position.distance_to(player.global_position)
	if distance > attack_range:
		state = "chase"
		return

	state = "attacking"
	velocity = Vector2.ZERO
	can_attack = false
	damaged_in_frame.clear()

	var chosen_attack = attack_animations[randi() % attack_animations.size()]
	sprite.play(chosen_attack)
	attack_timer.start(attack_cooldown)

	if has_node("AttackSound"):
		$AttackSound.play()

func take_damage(amount := 1):
	if state == "dead":
		return

	health = max(health - amount, 0)
	if health == 0:
		die()
	else:
		state = "hit"
		sprite.play("hit")
		if can_attack:
			pending_attack = true

func die():
	if is_dead:
		return
	is_dead = true  # Marcar como muerto

	state = "dead"
	velocity = Vector2.ZERO
	attack_area.monitoring = false
	area.monitoring = false
	attack_timer.stop()
	sprite.play("death")  # Reproducir animación de muerte

	if coin_scene:
		for i in range(10):
			var coin = coin_scene.instantiate()
			get_parent().add_child(coin)
		
		# Posición aleatoria cerca del enemigo
			var offset = Vector2(
				randf_range(-10, 10),  # horizontal
				randf_range(-5, 5)     # vertical
		)
			coin.global_position = global_position + offset


	var stage = get_tree().get_current_scene()
	if stage and stage.has_method("registrar_enemigo_derrotado"):
		stage.registrar_enemigo_derrotado()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		state = "chase"

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		state = "patrol"

func _on_attack_timer_timeout() -> void:
	can_attack = true
	if state not in ["dead", "attacking", "hit"]:
		state = "chase"

func _on_animation_animation_finished():
	if sprite.animation == "death" and is_dead:
		print("☠️ Animación de muerte finalizada. Liberando nodo.")
		queue_free()  # Liberar el nodo después de la animación de muerte
		return

	if is_dead:
		return  # Impide que se ejecute código adicional si el enemigo está muerto

	if sprite.animation in attack_animations and state == "attacking":
		damaged_in_frame.clear()
		state = "chase"
	elif sprite.animation == "hit":
		if pending_attack and can_attack:
			pending_attack = false
			attack()
		else:
			state = "chase"
