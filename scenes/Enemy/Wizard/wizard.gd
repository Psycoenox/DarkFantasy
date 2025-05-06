extends CharacterBody2D

@export var speed := 50
@export var gravity := 800
@export var max_fall_speed := 400
@export var patrol_points: Array[Vector2] = []
@export var attack_range := 80.0
@export var attack_cooldown := 1.0
@export var health := 3
@export var damage := 30

var patrol_index := 0
var player: Node2D = null
var state := "patrol"
var can_attack := true
var attack_animations := ["attack_1", "attack_2"]
var has_hit := false  # Control de daño por ataque

@onready var sprite := $Animation
@onready var area := $Area2D
@onready var attack_timer := $AttackTimer
@onready var attack_area := $AttackArea

func _ready():
	randomize()
	area.connect("body_entered", _on_area_2d_body_entered)
	area.connect("body_exited", _on_area_2d_body_exited)
	attack_timer.connect("timeout", _on_attack_timer_timeout)
	$Animation.connect("animation_finished", _on_animation_animation_finished)
	attack_area.monitoring = true
	sprite.play("idle")

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity.y = clamp(velocity.y, -9999, max_fall_speed)

	match state:
		"patrol":
			patrol_behavior()
		"chase":
			chase_behavior()
		"attacking":
			velocity.x = 0
			# 👇 Detección manual de daño mientras ataca
			if not has_hit:
				for body in attack_area.get_overlapping_bodies():
					if body.name == "Player" and body.has_method("take_damage"):
						print("💥 Golpeando al jugador (dentro del área)")
						body.take_damage(damage)
						has_hit = true

	move_and_slide()

func patrol_behavior():
	if patrol_points.is_empty():
		velocity.x = 0
		if sprite.animation != "idle":
			sprite.play("idle")
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

	var distance = global_position.distance_to(player.global_position)

	if distance <= attack_range and can_attack:
		attack()
	else:
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * speed
		sprite.flip_h = velocity.x < 0
		if sprite.animation != "run":
			sprite.play("run")

func attack():
	var distance = global_position.distance_to(player.global_position)
	if distance > attack_range:
		print("🚫 Jugador fuera de rango, cancelar ataque")
		state = "chase"
		return

	print("⚔️ Ataque del mago ejecutado")
	state = "attacking"
	velocity = Vector2.ZERO
	can_attack = false
	has_hit = false  # Reseteo de daño para este ataque

	var chosen_attack = attack_animations[randi() % attack_animations.size()]
	sprite.play(chosen_attack)
	attack_timer.start(attack_cooldown)

func take_damage():
	health -= 1
	sprite.play("hit")
	if health <= 0:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		state = "chase"

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		state = "patrol"

func _on_attack_timer_timeout() -> void:
	print("⏱️ Cooldown terminado")
	can_attack = true
	state = "chase"  # <- fuerza el reinicio aunque falle el callback

func _on_animation_animation_finished() -> void:
	if sprite.animation in attack_animations and state == "attacking":
		state = "chase"
