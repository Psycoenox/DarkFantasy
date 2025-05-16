extends ProgressBar

@export var player: Player

func _ready() -> void:
	if player:
		player.takedamage.connect(update)
		update()

func update() -> void:
	if player:
		value = float(player.health) * 100.0 / player.max_health
