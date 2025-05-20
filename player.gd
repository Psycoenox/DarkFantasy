class_name Player
extends CharacterBody2D

signal takedamage
signal stats_updated # señal para daño o vida

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
@export var max_health := 100
@export var health := max_health

var is_attacking := false
var coins := 999
var is_blocking := false
var is_special_attacking := false
var is_rolling := false
var can_attack := true
var combo_step := 0
var queued_combo := false
var current_attack_damage := 0
var can_move := true

# 🆕 Lista para evitar aplicar daño varias veces en un mismo ataque
var damaged_bodies := []

# 🆕 Diccionario con los daños por animación
var attack_damages = {
	"first_attack": base_attack_damage,
	"attack_combo_3": combo_2_damage,
	"full_combo_attack": combo_3_damage
}

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var invuln_timer: Timer = $InvulnTimer
@onready var world_map_scene := preload("res://scenes/Items/Maps/world_map.tscn")
func _ready():
	add_to_group("player")

func _physics_process(delta):
	var dir := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	if not can_move:
		return

	# 🪙 Atracción de monedas
	if Input.is_action_pressed("interact"):
		var coins = get_tree().get_nodes_in_group("coins")
		for coin in coins:
			if coin.global_position.distance_to(global_position) < 200:
				coin.attract_to_player(self)

	# 🛡️ BLOQUEO (solo activa animación una vez)
	if not is_attacking and not is_special_attacking and not is_rolling:
		if Input.is_action_pressed("block"):
			if not is_blocking:
				is_blocking = true
				sprite.play("block")
			velocity.x = 0  # No se mueve lateralmente al bloquear
		else:
			is_blocking = false

	# 🔁 MOVIMIENTO (solo si no está bloqueando ni rodando)
	if not is_rolling and not is_blocking:
		if is_on_floor():
			velocity.x = dir * speed
		else:
			velocity.x = lerp(velocity.x, dir * speed, air_control)

	# ⬇️ Gravedad siempre activa
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# ⛔ No puede saltar si está bloqueando
		if Input.is_action_just_pressed("jump") and not is_attacking and not is_special_attacking and not is_rolling and not is_blocking:
			velocity.y = jump_force

	# 🎞️ Animaciones
	if not is_attacking and not is_special_attacking and not is_rolling:
		if not is_on_floor():
			sprite.play("jump")
		elif dir != 0 and not is_blocking:
			sprite.play("walk")
		elif not is_blocking:
			sprite.play("idle")

	# 🔄 Flip
	if dir != 0:
		sprite.flip_h = dir < 0

	# ⚔️ ATAQUE
	if Input.is_action_just_pressed("attack"):
		if is_attacking:
			queued_combo = true
		elif can_attack and not is_special_attacking and not is_rolling and not is_blocking:
			start_attack("first_attack", 1)

	# ✨ ESPECIAL
	if Input.is_action_just_pressed("special") and not is_attacking and not is_special_attacking and not is_rolling and not is_blocking:
		start_special_attack()

	if Input.is_action_just_pressed("open_map"):
		if not get_tree().get_root().has_node("WorldMap"):
			var map = world_map_scene.instantiate()
			map.name = "WorldMap"
			get_tree().get_root().add_child(map)
			map.connect("mapa_cerrado", Callable(self, "_on_mapa_cerrado"))
			set_can_move(false)

	# 🪂 Clamped velocidad vertical
	velocity.y = clamp(velocity.y, -9999, max_fall_speed)
	move_and_slide()


# 🆕 Verificación por frame para aplicar daño mientras se ataca
func _process(delta):
	if is_attacking or is_special_attacking:
		for body in attack_area.get_overlapping_bodies():
			if not damaged_bodies.has(body) and body.has_method("take_damage"):
				damaged_bodies.append(body)
				body.take_damage(current_attack_damage)

func set_can_move(value: bool) -> void:
	can_move = value
	if not value:
		velocity = Vector2.ZERO
		sprite.play("idle")


func start_attack(anim_name: String, step: int):
	is_attacking = true
	can_attack = false
	combo_step = step
	queued_combo = false

	# 🆕 Limpiar lista de enemigos dañados
	damaged_bodies.clear()

	# 🆕 Asignar daño desde el diccionario
	current_attack_damage = attack_damages.get(anim_name, base_attack_damage)

	sprite.play(anim_name)
	attack_area.monitoring = true
	print("Iniciando ataque:", anim_name)

func start_special_attack():
	is_special_attacking = true
	current_attack_damage = special_damage
	damaged_bodies.clear()  # 🆕 Limpiar también para el ataque especial
	sprite.play("special_attack")
	attack_area.monitoring = true
	print("¡Ataque especial!")

func start_roll():
	is_rolling = true
	sprite.play("roll")
	print("Rodando e invulnerable")

func _on_animated_sprite_2d_animation_finished():
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
			pass

	is_attacking = false
	is_special_attacking = false
	is_rolling = false
	can_attack = true
	attack_area.monitoring = false
	queued_combo = false
	combo_step = 0

func take_damage(amount := 1):
	if invuln_timer.time_left > 0:
		print("⏳ Invulnerable, daño ignorado")
		return

	if is_blocking:
		print("🛡️ Bloqueo exitoso. Sin daño.")
		return

	health -= amount
	takedamage.emit()
	print("Player recibió %s de Daño. Salud: %s" % [amount, health])

	sprite.modulate = Color(1, 0.5, 0.5)
	invuln_timer.start(invuln_time)

	if health <= 0:
		die()
		
func _notification(what):
	if what == NOTIFICATION_EXIT_TREE and not get_tree().get_root().has_node("WorldMap"):
		set_can_move(true)

func _on_mapa_cerrado():
	set_can_move(true)

func collect_coin(amount:int) -> void:
	coins += amount
	print("Total de monedas: ", coins)
	
func upgrade_health(amount: int):
	max_health += amount
	health = max_health
	takedamage.emit()  # 🔄 Forzar actualización de barra de vida

func heal(amount: int):
	health += amount
	health = min(health, max_health)
	emit_signal("takedamage")  # Esto actualiza la barra de vida si usas esa señal


func die():
	print("Jugador ha muerto")
	sprite.play("death")  # ▶️ Reproducir animación de muerte
	can_move = false
	set_physics_process(false)  # Opcional: desactiva el movimiento mientras muere

	await sprite.animation_finished  # Esperar a que termine la animación

	get_tree().reload_current_scene()




# ❌ Ya no se necesita este método si usamos get_overlapping_bodies()
# func _on_attack_area_body_entered(body: Node2D) -> void:
#     if not is_attacking and not is_special_attacking:
#         return
#     if damaged_bodies.has(body):
#         return
#     if body.has_method("take_damage"):
#         damaged_bodies.append(body)
#         body.take_damage(current_attack_damage)
