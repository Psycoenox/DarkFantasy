extends Area2D

@export var speed = 300
@export var direction = Vector2.RIGHT

@onready var anim = $AnimatedSprite2D

var exploded = false

func _ready():
	anim.play("moving")

func _process(delta):
	if exploded:
		return
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if exploded:
		return

	if body.name == "Player":
		print("🔥 Proyectil impactó al jugador")
		if body.has_method("take_damage"):
			body.take_damage(30)  # O el valor que prefieras
		explode()

func explode():
	exploded = true
	anim.play("explode")
	$CollisionShape2D.disabled = true
	await anim.animation_finished
	queue_free()

func _on_timer_timeout() -> void:
	queue_free()
