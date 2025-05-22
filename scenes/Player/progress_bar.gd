extends ProgressBar

@export var player: Player  # Este se puede mantener para asignar manualmente si quieres
@onready var label: Label = $Label

func _ready() -> void:
	# Encuentra al player en la escena actual
	player = get_tree().get_current_scene().get_node_or_null("Player")

	if player:
		player.takedamage.connect(update)
		player.stats_updated.connect(update)
		
		# 🔁 Llamada inicial para forzar actualización del HUD
		update()


func update() -> void:
	if player:
		value = float(player.health) * 100.0 / player.max_health
		label.text = "%d / %d" % [player.health, player.max_health]
