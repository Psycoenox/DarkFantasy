extends Node2D

@onready var animation_player = $PointLight2D/AnimationPlayer

func _ready():
	animation_player.play("flicker")
