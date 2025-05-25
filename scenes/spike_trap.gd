extends Node2D

@export var damage := 100  # suficiente para matar
@export var instant_kill := true

func _ready():
	$Area2D.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))

func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		print("🔥 El jugador tocó los pinchos")
		body.take_damage(999)
