extends ProgressBar

@export var player: Player

@onready var label: Label = $Label  # Asegúrate de tener un Label como hijo del ProgressBar

func _ready() -> void:
	if player:
		player.takedamage.connect(update)
		player.stats_updated.connect(update)  # ✅ Escucha también mejoras
		update()


func update() -> void:
	if player:
		value = float(player.health) * 100.0 / player.max_health
		label.text = "%d / %d" % [player.health, player.max_health]
