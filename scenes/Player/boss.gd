extends CharacterBody2D

@export var gravity := 1000
@export var max_health := 100
@export var damage_flash_time := 0.1
@export var attack_damage := 40
@export var attack_cooldown := 1.5
@export var dash_speed := 150

var current_health := max_health
var is_alive := true
var can_attack := true
var is_attacking := false
var player_in_area: Node2D = null
var phase := 1
var phase2_triggered := false
var phase3_triggered := false


signal boss_defeated
@onready var body_collider = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer := Timer.new()
@onready var attack_damage_timer := Timer.new()
@onready var attack_shape := $AttackArea/CollisionShape2D


func _ready():
	sprite.play("idle")

	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.connect("timeout", _on_attack_timer_timeout)
	add_child(attack_timer)

	attack_damage_timer.wait_time = 0.5
	attack_damage_timer.one_shot = false
	attack_damage_timer.connect("timeout", _on_attack_damage_tick)
	add_child(attack_damage_timer)

	attack_area.connect("body_entered", _on_attack_area_body_entered)
	attack_area.connect("body_exited", _on_attack_area_body_exited)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	move_and_slide()

	# Si el jugador está cerca y puede atacar
	if player_in_area and can_attack and not is_attacking:
		start_attack(player_in_area)

func take_damage(amount := 1):
	if not is_alive:
		return

	current_health -= amount
	print("💢 Boss herido:", current_health, "HP")
	sprite.play("hit")
	await sprite.animation_finished
	sprite.play("idle")

	if not phase2_triggered and current_health <= 75:
		enter_phase_2()
	if not phase3_triggered and current_health <= 50:
		enter_phase_3()

	if current_health <= 0:
		die()

func die():
	is_alive = false
	print("☠️ Boss derrotado, emitiendo señal")
	emit_signal("boss_defeated")
	queue_free()

func enter_phase_2():
	phase = 2
	phase2_triggered = true
	attack_cooldown = 1.2
	sprite.modulate = Color(1, 0.7, 0.3)
	print("🔥 FASE 2 ACTIVADA")

	# Expandir el área de ataque (círculo)
	if attack_shape.shape is CircleShape2D:
		attack_shape.shape.radius = 100  # ajusta el radio como desees
		
func enter_phase_3():
	phase = 3
	phase3_triggered = true
	attack_cooldown = 0.8
	sprite.modulate = Color(1, 0.2, 0.2)
	print("💀 FASE 3 ACTIVADA")

	# Restaurar radio del área de ataque
	if attack_shape.shape is CircleShape2D:
		attack_shape.shape.radius = 40  # ← valor original


func start_attack(target):
	can_attack = false
	is_attacking = true

	match phase:
		1:
			sprite.play("attack_1")
			await get_tree().create_timer(0.3).timeout
		2:
			sprite.play("dash")
			await dash_towards_player()
		3:
			sprite.play("attack_2")
			await get_tree().create_timer(0.3).timeout

	if player_in_area:
		attack_damage_timer.start()

	await sprite.animation_finished
	sprite.play("idle")
	is_attacking = false
	attack_damage_timer.stop()
	attack_timer.start()


func dash_towards_player():
	# Al terminar el dash, mira hacia el jugador
	if player_in_area:
		var direction = (player_in_area.global_position - global_position).normalized()
		sprite.flip_h = direction.x < 0	
	if not player_in_area:
		return

	var direction = (player_in_area.global_position - global_position).normalized()
	var dash_direction: int = sign(direction.x)
	sprite.flip_h = dash_direction < 0

	# 💥 Ignora al jugador durante el dash (pero no al suelo)
	set_collision_mask(1)

	var dash_time: float = 0.4
	var elapsed: float = 0.0

	while elapsed < dash_time:
		velocity.x = dash_direction * dash_speed
		move_and_slide()
		await get_tree().process_frame
		elapsed += get_process_delta_time()

	velocity.x = 0

	# ✅ Vuelve a detectar al jugador después del dash
	set_collision_mask(1 | 2)








func _on_attack_damage_tick():
	if player_in_area and player_in_area.has_method("take_damage"):
		player_in_area.take_damage(attack_damage)

func _on_attack_area_body_entered(body):
	if body.name == "Player":
		player_in_area = body
		if is_attacking:
			attack_damage_timer.start()

func _on_attack_area_body_exited(body):
	if body == player_in_area:
		player_in_area = null
		attack_damage_timer.stop()

func _on_attack_timer_timeout():
	can_attack = true
	
	
