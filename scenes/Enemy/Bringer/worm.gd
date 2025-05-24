extends CharacterBody2D

@export var shoot_cooldown := 2.0
@export var projectile_scene: PackedScene = preload("res://scenes/Enemy/WizardBoss/projectile.tscn")
@export var detection_range := 400.0
@export var health := 60
@export var gravity := 800.0
@export var max_fall_speed := 1000.0
@export var stop_distance := 240.0

var max_health := health
var player: Node2D = null
var is_attacking := false
var has_fired := false
var is_hurt := false
var is_dead := false

@onready var sprite := $AnimatedSprite2D
@onready var shoot_point := $ShootPoint
@onready var timer := $ShootTimer

func _ready():
	add_to_group("enemy")
	timer.wait_time = shoot_cooldown
	timer.connect("timeout", _on_shoot_timer_timeout)
	sprite.connect("frame_changed", _on_frame_changed)
	timer.start()

func _physics_process(delta):
	if is_dead:
		return
	#DEBUG
	#print("Vida actual: ", health)
	# ✅ Búsqueda flexible del jugador por grupo
	if not player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]

	if player:
		var distance := global_position.distance_to(player.global_position)

		if is_attacking:
			velocity.x = 0
		elif distance > stop_distance and distance <= detection_range:
			sprite.flip_h = player.global_position.x < global_position.x
			shoot_point.position.x = -abs(shoot_point.position.x) if sprite.flip_h else abs(shoot_point.position.x)
			if sprite.animation != "run":
				sprite.play("run")
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * 50
		else:
			velocity.x = 0
			if sprite.animation != "idle":
				sprite.play("idle")

		# Asegurar orientación del shoot point
		shoot_point.position.x = -abs(shoot_point.position.x) if sprite.flip_h else abs(shoot_point.position.x)

	# Gravedad
	velocity.y += gravity * delta
	velocity.y = clamp(velocity.y, -9999, max_fall_speed)
	move_and_slide()

func _on_shoot_timer_timeout():
	if is_dead or not player or global_position.distance_to(player.global_position) > detection_range:
		return

	is_attacking = true
	has_fired = false
	sprite.play("attack")

func _on_frame_changed():
	if is_dead:
		return
	if sprite.animation == "attack" and sprite.frame == 9 and not has_fired:
		sprite.flip_h = player.global_position.x < global_position.x
		shoot_point.position.x = -abs(shoot_point.position.x) if sprite.flip_h else abs(shoot_point.position.x)
		_fire_projectile()
		has_fired = true

func _fire_projectile():
	var p = projectile_scene.instantiate()
	get_tree().current_scene.add_child(p)
	p.global_position = shoot_point.global_position

	var dir = Vector2(player.global_position.x - shoot_point.global_position.x, 0).normalized()
	p.direction = dir

	if p.has_node("AnimatedSprite2D"):
		p.get_node("AnimatedSprite2D").flip_h = dir.x < 0

	print("🧭 Dirección del proyectil:", dir)
	print("🔫 Proyectil disparado")

	# ✅ Reproducir sonido de disparo
	if has_node("AttackSound"):
		$AttackSound.play()


func take_damage(amount := 1):
	if is_dead:
		print("☠️ Ya está muerto, ignorar daño.")
		return

	health -= amount
	print("💢 Daño recibido: ", amount, " | Salud restante: ", health, "/", max_health)

	if health <= 0:
		print("💀 Vida agotada. Ejecutando muerte.")
		die()
		return

	# Reproducir animación hit solo si aún no se está reproduciendo
	if sprite.animation != "hit" and sprite.animation != "death":
		sprite.play("hit")




func die():
	var stage = get_tree().get_current_scene()
	if stage and stage.has_method("registrar_enemigo_derrotado"):
		stage.registrar_enemigo_derrotado()
	if is_dead:
		return
	is_dead = true
	is_attacking = false
	timer.stop()
	$CollisionShape2D.disabled = true
	sprite.play("death")
	await sprite.animation_finished
	queue_free()

func _on_animated_sprite_2d_animation_finished():
	if is_dead:
		return
	if sprite.animation == "attack":
		is_attacking = false
		sprite.play("idle")
