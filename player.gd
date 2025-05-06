extends CharacterBody2D

@export var speed := 120
@export var jump_force := -400
@export var gravity := 1000
@export var max_fall_speed := 1000
@export var invuln_time := 1.0
@export var air_control := 0.5
@export var base_attack_damage := 10
@export var combo_2_damage := 35
@export var combo_3_damage := 50
@export var special_damage := 75
@export var health = 100

var is_attacking := false
var is_blocking := false
var is_special_attacking := false
var is_rolling := false
var can_attack := true
var combo_step := 0
var queued_combo := false
var current_attack_damage := 0
var can_move := true


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var invuln_timer: Timer = $InvulnTimer

func _physics_process(delta):
	var dir := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	if not can_move:
		return
	# Bloqueo (se mantiene presionado)
	if Input.is_action_pressed("block") and not is_attacking and not is_special_attacking and not is_rolling:
		is_blocking = true
		sprite.play("block")
		velocity.x = 0  # No puedes moverte mientras bloqueas
		return
	else:
		is_blocking = false

	# Detectar input de roll (solo si te estás moviendo y no estás ocupado)
	if Input.is_action_just_pressed("roll") and not is_attacking and not is_special_attacking and not is_rolling and abs(dir) > 0:
		start_roll()
		return

	# Movimiento solo si no estás rodando
	if not is_rolling:
		if is_on_floor():
			velocity.x = dir * speed
		else:
			velocity.x = lerp(velocity.x, dir * speed, air_control)

	# Gravedad y salto
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if Input.is_action_just_pressed("jump") and not is_attacking and not is_special_attacking and not is_rolling:
			velocity.y = jump_force

	# Animaciones
	if not is_attacking and not is_special_attacking and not is_rolling:
		if not is_on_floor():
			sprite.play("jump")
		elif dir != 0:
			sprite.play("walk")
		else:
			sprite.play("idle")

	# Flip
	if dir != 0:
		sprite.flip_h = dir < 0

	# Ataque normal
	if Input.is_action_just_pressed("attack"):
		if is_attacking:
			queued_combo = true
		elif can_attack and not is_special_attacking and not is_rolling:
			start_attack("first_attack", 1)

	# Ataque especial
	if Input.is_action_just_pressed("special") and not is_attacking and not is_special_attacking and not is_rolling:
		start_special_attack()

	velocity.y = clamp(velocity.y, -9999, max_fall_speed)
	move_and_slide()

func set_can_move(value: bool) -> void:
	can_move = value

func start_attack(anim_name: String, step: int):
	is_attacking = true
	can_attack = false
	combo_step = step
	queued_combo = false

	match anim_name:
		"first_attack":
			current_attack_damage = base_attack_damage
		"attack_combo_3":
			current_attack_damage = combo_2_damage
		"full_combo_attack":
			current_attack_damage = combo_3_damage

	sprite.play(anim_name)
	attack_area.monitoring = true
	print("Iniciando ataque:", anim_name)

func start_special_attack():
	is_special_attacking = true
	current_attack_damage = special_damage
	sprite.play("special_attack")
	attack_area.monitoring = true
	print("¡Ataque especial!")

func start_roll():
	is_rolling = true
	sprite.play("roll")
	print("Rodando e invulnerable")

func _on_animated_sprite_2d_animation_finished():
	print("Animación terminada:", sprite.animation)

	match sprite.animation:
		"first_attack":
			if queued_combo:
				start_attack("attack_combo_3", 2)
				return
		"attack_combo_3":
			if queued_combo:
				start_attack("full_combo_attack", 3)
				return
		"full_combo_attack", "special_attack", "roll":
			print("Acción terminada.")

# 💥 Fin de cualquier acción, limpiamos
	is_attacking = false
	is_special_attacking = false
	is_rolling = false
	can_attack = true
	attack_area.monitoring = false
	queued_combo = false
	combo_step = 0


func take_damage(amount := 1):
	if is_blocking:
		print("🛡️ Bloqueo exitoso. Sin daño.")
		return

	# Si no es invulnerable ni está bloqueando, recibe daño
	health -= amount
	print("Player recibió " + str(amount) + " de Daño. Salud: " + str(health))

	if health <= 0:
		die()

	print("😵 Recibido daño:", amount)
	sprite.modulate = Color(1, 0.5, 0.5)
	invuln_timer.start(invuln_time)

func die():
	print("Jugador ha muerto")
	get_tree().reload_current_scene()
	# Aquí puedes reproducir una animación, reiniciar el nivel, etc.

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(current_attack_damage)
