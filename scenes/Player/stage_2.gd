extends Node2D
@onready var animation_player = $

func _ready():
	animation_player.play("flicker")
