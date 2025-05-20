extends RigidBody2D

@export var heal_amount := 30
@export var rotation_speed := 5.0  # Puedes ajustar la velocidad de rotación

func _ready():
	angular_velocity = rotation_speed
	$PotionArea.connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":  # o: if body is Player
		if body.has_method("heal"):
			body.heal(heal_amount)
		queue_free()
