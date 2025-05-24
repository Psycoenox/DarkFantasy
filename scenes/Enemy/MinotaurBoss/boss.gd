extends CharacterBody2D

@export var speed := 100.0
@export var gravity := 1200.0
@export var max_health := 100
@export var armor_hits := 5
@export var stun_duration := 2.0
@export var attack_range := 150.0
@export var attack_cooldown := 1.0

@export var health_bar_path: NodePath

@onready var detection_area: Area2D = $DetectionArea
@onready var boss_health_bar: TextureProgressBar = get_node(health_bar_path)
@onready var anim_sprite := $AnimatedSprite2D
@onready var boss_breath: AudioStreamPlayer2D = $BossBreath
@onready var credits_scene := preload("res://scenes/Credits.tscn")


var health := max_health
var current_hits := 0
var is_stunned := false
var is_dead := false
var is_attacking := false
var can_attack := true
var target: Node2D = null
var rng := RandomNumberGenerator.new()

var frames_de_danio := []
var animacion_actual_daniando := ""
var ya_golpeado_en_frame := {}
var dano_por_golpe := 10  # Nuevo: configurable por ataque

func _ready():
	$DetectionArea.body_entered.connect(_on_detection_area_body_entered)
	$DetectionArea.body_exited.connect(_on_detection_area_body_exited)

	rng.randomize()
	anim_sprite.play("idle")

	if boss_health_bar:
		boss_health_bar.max_value = max_health
		boss_health_bar.value = health
	else:
		print("❌ No se encontró la barra de vida (HealthBar)")

func _physics_process(delta):
	# Buscar jugador dentro de DetectionArea si no hay target asignado
	if detection_area:
		for body in detection_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				target = body
				break

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if is_stunned or is_attacking:
		velocity.x = 0
	else:
		if target:
			var distance = global_position.distance_to(target.global_position)
			var direction = sign(target.global_position.x - global_position.x)
			anim_sprite.flip_h = direction > 0  # ↔️ Mira hacia el jugador

			if distance > attack_range:
				velocity.x = direction * speed
				anim_sprite.play("walk")
			else:
				velocity.x = 0
				if can_attack:
					perform_attack()
		else:
			velocity.x = 0
			anim_sprite.play("idle")

	move_and_slide()


func _process(delta):
	if detection_area:
		var bodies = detection_area.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player"):
				target = body  # Asignar constantemente como target
				break
	# Reproducir sonido en frame 7 de la animación idle
	if anim_sprite.animation == "idle" and anim_sprite.frame == 7:
		if not boss_breath.playing:
			boss_breath.play()

	# Control de animación de ataque para aplicar daño por frame
	if anim_sprite.animation == animacion_actual_daniando:
		var frame = anim_sprite.frame
		var key = anim_sprite.animation + ":" + str(frame)

		if frames_de_danio.has(frame) and not ya_golpeado_en_frame.has(key):
			try_hit_player()
			ya_golpeado_en_frame[key] = true
	else:
		animacion_actual_daniando = ""


func preparar_danio(animacion: String, frames: Array[int], dano: int = 10):
	frames_de_danio = frames
	animacion_actual_daniando = animacion
	ya_golpeado_en_frame.clear()
	dano_por_golpe = dano

func take_damage(amount: int):
	if is_dead:
		return
	if is_stunned or anim_sprite.animation == "Death":
		return

	if current_hits >= armor_hits:
		enter_stun()
		return

	if current_hits == armor_hits - 1 and should_block():
		anim_sprite.play("Block")
		current_hits = max(0, current_hits - 2)
		health -= int(amount * 0.25)
	else:
		health -= amount
		current_hits += 1

	if boss_health_bar:
		boss_health_bar.value = health

	if health <= 0:
		die()

func enter_stun():
	is_stunned = true
	anim_sprite.play("hit")
	current_hits = 0
	await get_tree().create_timer(stun_duration).timeout
	is_stunned = false
	anim_sprite.play("idle")

func should_block() -> bool:
	return rng.randi_range(0, 100) < 70

func die():
	if is_dead:
		return
	is_dead = true

	anim_sprite.play("Death")
	set_physics_process(false)
	$CollisionShape2D.disabled = true

	if boss_health_bar:
		boss_health_bar.hide()

	await anim_sprite.animation_finished

	await get_tree().create_timer(2.0).timeout

	var credits = credits_scene.instantiate()
	get_tree().get_root().add_child(credits)

	queue_free()




func attack_combo():
	can_attack = false
	is_attacking = true

	anim_sprite.play("Attack_1")
	preparar_danio("Attack_1", [4, 5, 10], 6)
	await anim_sprite.animation_finished

	anim_sprite.play("Attack_2")
	preparar_danio("Attack_2", [9, 10], 6)
	await anim_sprite.animation_finished

	anim_sprite.play("idle")
	is_attacking = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func attack_spinning():
	can_attack = false
	is_attacking = true

	anim_sprite.play("Attack_Spinning")
	preparar_danio("Attack_Spinning", [5, 7, 8, 10], 10)  # Aplica 10 de daño por cada frame
	await anim_sprite.animation_finished

	anim_sprite.play("idle")
	is_attacking = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func perform_attack():
	if not can_attack:
		print("No puede atacar todavía")
		return

	print("¡BOSS ATACA!")
	var chance = rng.randi_range(0, 99)
	if chance < 50:
		await attack_spinning()
	else:
		await attack_combo()

func try_hit_player():
	if target and global_position.distance_to(target.global_position) <= attack_range:
		if target.has_method("take_damage"):
			print("Golpe al jugador en frame:", anim_sprite.frame)
			target.take_damage(dano_por_golpe)
		else:
			print("El target no tiene método take_damage()")
	else:
		print("Jugador fuera de rango")

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Jugador detectado:", body.name)
		target = body

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body == target:
		print("Jugador salió del área")
		target = null


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body
		print("🎯 Jugador detectado por DetectionArea")

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		print("👁️ Jugador salió del DetectionArea")
