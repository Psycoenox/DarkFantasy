extends CharacterBody2D

@export var speed := 50
@export var gravity := 800
@export var max_fall_speed := 400
@export var patrol_points: Array[Vector2] = []
@export var attack_range := 80.0
@export var attack_cooldown := 8.0
@export var health := 80
@export var damage := 30
@export var coin_scene: PackedScene

var patrol_index := 0
var player: Node2D = null
var state := "patrol"
var can_attack := true
var attack_animations := ["attack_1", "attack_2"]
var has_hit := false
var pending_attack := false

# ✅ NUEVO: control de daño por frame
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

func _physics_process(delta):
	if state == "dead":
		velocity.x = 0
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
	if patrol_points.is_empty():
		velocity.x = 0
		if sprite.animation not in ["run", "idle"]:
			sprite.play("run")
		return

	var target = patrol_points[patrol_index]
	var direction = (target - global_position).normalized()
	velocity.x = direction.x * speed
	sprite.flip_h = velocity.x < 0

	if sprite.animation != "run":
		sprite.play("run")

	if global_position.distance_to(target) < 5:
		patrol_index = (patrol_index + 1) % patrol_points.size()

func chase_behavior():
	if not player:
		state = "patrol"
		return

	if attack_area.get_overlapping_bodies().has(player):
		if can_attack:
			attack()
		else:
			velocity.x = 0
			if sprite.animation != "idle":
				sprite.play("idle")
		return

	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * speed
	sprite.flip_h = velocity.x < 0

	if sprite.animation != "run":
		sprite.play("run")

func attack():
	if state == "dead":
		return

	var distance = global_position.distance_to(player.global_position)
	if distance > attack_range:
		print("🚫 Jugador fuera de rango, cancelar ataque")
		state = "chase"
		return

	print("⚔️ Ataque del mago ejecutado")
	state = "attacking"
	velocity = Vector2.ZERO
	can_attack = false
	has_hit = false
	damaged_in_frame.clear()  # ✅ limpiar frames al comenzar ataque

	var chosen_attack = attack_animations[randi() % attack_animations.size()]
	sprite.play(chosen_attack)
	attack_timer.start(attack_cooldown)

func take_damage(amount := 1):
	if state == "dead":
		return

	health = max(health - amount, 0)
	print("🧙 El enemigo recibió ", amount, " de daño. Salud restante: ", health)

	if health == 0:
		die()
		return

	state = "hit"
	sprite.play("hit")

	if can_attack:
		pending_attack = true

func die():
	state = "dead"
	velocity = Vector2.ZERO
	attack_area.monitoring = false
	area.monitoring = false
	attack_timer.stop()
	sprite.play("death")
	print("☠️ El enemigo ha muerto.")

	if coin_scene:
		var coin = coin_scene.instantiate()
		get_parent().add_child(coin)
		coin.global_position = global_position
		print("💰 Moneda generada en posición: ", coin.global_position)
	else:
		print("⚠️ coin_scene no asignado")

	var stage = get_tree().get_current_scene()
	if stage and stage.has_method("registrar_enemigo_derrotado"):
		stage.registrar_enemigo_derrotado()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if state == "dead":
		return

	if body.name == "Player":
		player = body
		state = "chase"

func _on_area_2d_body_exited(body: Node2D) -> void:
	if state == "dead":
		return

	if body == player:
		player = null
		state = "patrol"

func _on_attack_timer_timeout() -> void:
	print("⏱️ Cooldown terminado")
	can_attack = true

	if state != "dead" and state != "attacking" and state != "hit":
		state = "chase"

func _on_animation_animation_finished():
	print("🌀 Animación terminada:", sprite.animation, " | Estado:", state)

	if sprite.animation in attack_animations and state == "attacking":
		damaged_in_frame.clear()  # ✅ limpiar después de ataque
		state = "chase"
	elif sprite.animation == "hit":
		if pending_attack and can_attack:
			pending_attack = false
			attack()
		else:
			state = "chase"
	elif sprite.animation == "death":
		print("☠️ Animación de muerte terminada")
		queue_free()
