extends CanvasLayer

@onready var coin_label = $HBoxContainer/Label  # o el path correcto

func _ready():
	if coin_label:
		coin_label.text = "x 0"

func actualizar_monedas(cantidad: int):  # ✅ nombre mejor para llamar a mano
	coin_label.text = "x %d" % cantidad

func setear_player(player):
	player.monedas_actualizadas.connect(actualizar_monedas)
	actualizar_monedas(player.coins)  # Mostrar valor inicial
