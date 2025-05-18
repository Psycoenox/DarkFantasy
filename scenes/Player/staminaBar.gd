extends ProgressBar

@export var player: Player

func _process(delta: float) -> void:
	if player:
		value = float(player.stamina) * 100.0 / player.max_stamina
