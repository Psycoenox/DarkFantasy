extends ProgressBar

@export var player: Player  # Asignable manualmente si quieres
@onready var label: Label = $Label

func _ready() -> void:
	# Encuentra automáticamente al player en la escena actual
	player = get_tree().get_current_scene().get_node_or_null("Player")

	if player:
		player.mana_changed.connect(update)
		player.stats_updated.connect(update)

		# Inicializa la barra con los valores actuales
		update()


func update() -> void:
	if player:
		value = float(player.mana) * 100.0 / player.max_mana
		label.text = "%d / %d" % [player.mana, player.max_mana]
