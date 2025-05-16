extends CharacterBody2D

@export var shoot_cooldown := 2.0
@export var projectile_scene: PackedScene = preload("res://scenes/Enemy/WizardBoss/projectile.tscn")
@export var detection_range := 400.0
@export var health := 100
@export var gravity := 800.0
@export var max_fall_speed := 1000.0
@export var stop_distance := 240.0  # distancia mínima para dejar de caminar y solo atacar
@export var summon_scene: PackedScene = preload("res://scenes/Enemy/Wizard/wizard.tscn")

var max_health := health
var player: Node2D = null
var is_attacking := false
var has_fired := false  # Para evitar múltiples disparos por ataque
var has_summoned := false
var is_hurt := false
var is_dead := false


@onready var sprite := $AnimatedSprite2D
@onready var shoot_point := $ShootPoint
@onready var timer := $ShootTimer
@onready var summon_point := $SummonPoint

func _ready():
	timer.wait_time = shoot_cooldown
	timer.connect("timeout", _on_shoot_timer_timeout)
	sprite.connect("frame_changed", _on_frame_changed)
	timer.start()

func _physics_process(delta):
	if is_dead:
		return
	if not player:
		player = get_tree().get_root().get_node_or_null("Stage3/Player")

	if player:
		var distance := global_position.distance_to(player.global_position)

		# Si está atacando, que no se mueva
		if is_attacking:
			velocity.x = 0
		elif distance > stop_distance and distance <= detection_range:
			# Si está lejos pero en rango, camina hacia el jugador
			sprite.flip_h = player.global_position.x < global_position.x
			if sprite.flip_h:
				shoot_point.position.x = -abs(shoot_point.position.x)
			else:
				shoot_point.position.x = abs(shoot_point.position.x)
			if sprite.animation != "run":
				sprite.play("run")
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * 50
		else:
			# Está en rango de ataque (cerca), quedarse quieto
			velocity.x = 0
			if sprite.animation != "idle":
				sprite.play("idle")

		# Flip del shoot point
		if sprite.flip_h:
			shoot_point.position.x = -abs(shoot_point.position.x)
		else:
			shoot_point.position.x = abs(shoot_point.position.x)

	# Gravedad
	velocity.y += gravity * delta
	velocity.y = clamp(velocity.y, -9999, max_fall_speed)
	move_and_slide()



func _on_shoot_timer_timeout():
	if is_dead or not player or global_position.distance_to(player.global_position) > detection_range:
		return

	is_attacking = true
	has_fired = false  # Resetear bandera de disparo
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
		var sprite_node = p.get_node("AnimatedSprite2D")
		sprite_node.flip_h = dir.x < 0

	print("🧭 Dirección del proyectil:", dir)
	print("🔫 Proyectil disparado")

func take_damage(amount := 1):
	if is_dead:
		return
	health -= amount
	sprite.play("hit")

	if is_hurt:
		return
	health -= amount
	is_hurt = true
	sprite.play("hit")
	
	if health <= 0:
		die()
	else:
		await sprite.animation_finished
		is_hurt = false
		
	if not has_summoned and health <= max_health / 2:
		has_summoned = true
		summon_enemy()

	if health <= 0:
		die()

func summon_enemy():
	var new_enemy = summon_scene.instantiate()
	get_parent().add_child(new_enemy)
	new_enemy.global_position = summon_point.global_position


func die():
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
