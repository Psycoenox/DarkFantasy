class_name Player
extends CharacterBody2D

signal takedamage
signal stats_updated # señal para daño o vida
signal mana_changed
signal monedas_actualizadas(cantidad: int)


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
@export var max_mana := 100
@export var special_mana_cost := 50

var is_attacking := false
var mana := max_mana
var coins := 100
var is_blocking := false
var is_special_attacking := false
var is_rolling := false
var can_attack := true
var combo_step := 0
var queued_combo := false
var current_attack_damage := 0
var can_move := true
var damage_frames := {
	"first_attack": [4, 5],
	"attack_combo_3": [4, 5, 7, 8],
	"full_combo_attack": [4, 5, 6],
	"special_attack":[12,13,14]
}
var already_hit_this_frame := {}
var active_damage_frames := []


# 🆕 Lista para evitar aplicar daño varias veces en un mismo ataque
var damaged_bodies := []

# 🆕 Diccionario con los daños por animación
var attack_damages = {
	"first_attack": base_attack_damage,
	"attack_combo_3": combo_2_damage,
	"full_combo_attack": combo_3_damage
}
var attack_offset_x: float

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var first_attack_sound := $FirstAttackSound
@onready var combo3_sound := $Combo3Sound
@onready var full_combo_sound := $FullComboSound
@onready var special_attack_sound := $SpecialAttackSound
@onready var world_map_scene := preload("res://scenes/Items/Maps/world_map.tscn")

func _ready():
	if SaveSystem.loaded_data.has("player_position"):
		global_position = Vector2(
			SaveSystem.loaded_data["player_position"]["x"],
			SaveSystem.loaded_data["player_position"]["y"]
		)
	if SaveSystem.loaded_data.has("player_health"):
		health = SaveSystem.loaded_data["player_health"]
	if SaveSystem.loaded_data.has("player_max_health"):
		max_health = SaveSystem.loaded_data["player_max_health"]
	if SaveSystem.loaded_data.has("coins"):
		coins = SaveSystem.loaded_data["coins"]

	# ✅ SOLO usar PlayerData si NO estás cargando desde save
	if SaveSystem.loaded_data.is_empty():
		max_health = PlayerData.max_health
		health = PlayerData.health
		base_attack_damage = PlayerData.attack_damage
		coins = PlayerData.coins

	# ✅ Aquí ya puedes limpiar
	SaveSystem.loaded_data.clear()

	add_to_group("player")
	$ManaRegenTimer.timeout.connect(_on_mana_regen_timer_timeout)

	# 🔒 Solo aplicar upgrades si aún no se aplicaron
	if not PlayerData.upgrades_applied:
		apply_upgrades()
		PlayerData.upgrades_applied = true

	stats_updated.emit()

	
	print("🧪 Vida final tras aplicar upgrades: %d / %d" % [health, max_health])
	attack_offset_x = attack_area.position.x
	$CanvasLayer.setear_player(self)




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
	# 🔄 Flip
	if dir != 0:
		var flipped := dir < 0
		if sprite.flip_h != flipped:
			sprite.flip_h = flipped
			attack_area.scale.x = -0.25 if sprite.flip_h else 1


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

func apply_upgrades():
	var health_lvl = PlayerData.upgrades.health_lvl
	var damage_lvl = PlayerData.upgrades.damage_lvl

	# Mejora la vida según nivel
	max_health += health_lvl * 10
	health = max_health

	# Mejora el daño base
	base_attack_damage += damage_lvl * 5

	# Actualiza daños en el diccionario si lo usas
	attack_damages["first_attack"] = base_attack_damage

	print("🟢 Mejoras aplicadas: +%d vida, +%d daño" % [health_lvl * 10, damage_lvl * 5])

func _process(_delta):
	# 🔁 Regeneración pasiva de maná
	if mana < max_mana:
		mana += 10 * _delta
		mana = min(mana, max_mana)
		mana_changed.emit()

	# 💥 Verificación por frame para aplicar daño durante ataques
	if is_attacking or is_special_attacking:
		var current_anim = sprite.animation
		var current_frame = sprite.frame

		if damage_frames.has(current_anim):
			if current_frame in damage_frames[current_anim] and not already_hit_this_frame.has(current_frame):
				for body in attack_area.get_overlapping_bodies():
					if body.has_method("take_damage") and not damaged_bodies.has(body):
						body.take_damage(current_attack_damage)
						damaged_bodies.append(body)
						print("💥 Daño aplicado en frame:", current_frame)

				# 🔊 Efectos de sonido por tipo de ataque
				if current_anim == "special_attack" and current_frame == 13 and special_attack_sound:
					special_attack_sound.play()
				elif current_anim == "attack_combo_3" and combo3_sound:
					combo3_sound.play()

				already_hit_this_frame[current_frame] = true
	else:
		already_hit_this_frame.clear()




func set_can_move(value: bool) -> void:
	can_move = value
	if not value:
		velocity = Vector2.ZERO
		sprite.play("idle")




func recover_mana(amount: int):
	mana += amount
	mana = min(mana, max_mana)
	mana_changed.emit()  # 🔁 Actualizar la UI

func start_attack(anim_name: String, step: int):
	is_attacking = true
	can_attack = false
	combo_step = step
	queued_combo = false

	damaged_bodies.clear()
	already_hit_this_frame.clear()

	current_attack_damage = attack_damages.get(anim_name, base_attack_damage)
	sprite.play(anim_name)
	attack_area.monitoring = true
	print("Iniciando ataque:", anim_name)

	if damage_frames.has(anim_name):
		active_damage_frames = damage_frames[anim_name].duplicate() as Array[int]
	else:
		active_damage_frames = []

	# 🔊 Reproducir sonido correspondiente al ataque
	match anim_name:
		"first_attack":
			if first_attack_sound:
				first_attack_sound.play()
		"full_combo_attack":
			if full_combo_sound:
				full_combo_sound.play()




func start_special_attack():
	if mana < special_mana_cost:
		print("❌ No hay suficiente maná para el ataque especial.")
		return

	is_special_attacking = true
	current_attack_damage = special_damage
	damaged_bodies.clear()
	sprite.play("special_attack")
	attack_area.monitoring = true

	mana -= special_mana_cost
	mana = max(0, mana)
	mana_changed.emit()  # 🔁 Notificar a la UI
	print("✨ ¡Ataque especial lanzado! Maná restante:", mana)



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
	if is_blocking:
		print("🛡️ Bloqueo exitoso. Sin daño.")
		return

	health -= amount
	health = max(0, health)
	takedamage.emit()
	print("Player recibió %s de Daño. Salud: %s" % [amount, health])

	sprite.modulate = Color(1, 0.5, 0.5)

	if health > 0:
		sprite.play("hit")

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
	PlayerData.coins = coins  # ✅ Actualiza el valor persistente
	emit_signal("monedas_actualizadas", coins)

	
func upgrade_health(amount: int):
	max_health += amount
	health = max_health
	takedamage.emit()  # 🔄 Forzar actualización de barra de vida

func heal(amount: int):
	health += amount
	health = min(health, max_health)
	emit_signal("takedamage")  # Esto actualiza la barra de vida si usas esa señal

func save_player_data():
	PlayerData.max_health = max_health
	PlayerData.health = health
	PlayerData.attack_damage = base_attack_damage
	PlayerData.coins = coins

func die():
	save_player_data()
	print("Jugador ha muerto")
	sprite.play("death")
	can_move = false
	set_physics_process(false)

	await sprite.animation_finished

	# 🔁 Restaurar salud antes de reiniciar
	PlayerData.health = PlayerData.max_health

	get_tree().call_deferred("reload_current_scene")


func _on_mana_regen_timer_timeout():
	if mana < max_mana:
		mana += 1
		mana = min(mana, max_mana)
		mana_changed.emit()
