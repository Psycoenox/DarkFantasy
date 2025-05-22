extends CanvasLayer

signal mapa_cerrado

@onready var button_zona1 = $ButtonZona1
@onready var button_zona2 = $ButtonZona2
@onready var button_zona3 = $ButtonZona3
@onready var button_zona4 = $ButtonZona4

const STAGE_PATHS = {
	"zona1": "res://scenes/Levels/stage_1.tscn",
	"zona2": "res://scenes/Levels/stage_2.tscn",
	"zona3": "res://scenes/Levels/stage_3.tscn",
	"zona4": "res://scenes/Levels/stage_final.tscn"
}

var mission_progress = {
	"zona1": false,
	"zona2": false,
	"zona3": false,
	"zona4": false
}

func _ready():
	visible = false
	update_buttons()

	button_zona1.pressed.connect(func(): _ir_a_zona("zona1"))
	button_zona2.pressed.connect(func(): _ir_a_zona("zona2"))
	button_zona3.pressed.connect(func(): _ir_a_zona("zona3"))
	button_zona4.pressed.connect(func(): _ir_a_zona("zona4"))

func update_buttons():
	button_zona1.disabled = false
	button_zona2.disabled = !GameManager.desbloquear_zona("2")
	button_zona3.disabled = !GameManager.desbloquear_zona("3")
	button_zona4.disabled = !GameManager.desbloquear_zona("4")

func _input(event):
	if event.is_action_pressed("open_map"):
		visible = not visible
		if visible:
			update_buttons()

func _ir_a_zona(zona: String) -> void:
	if STAGE_PATHS.has(zona):
		# Guarda los datos del jugador antes de cambiar de nivel
		var current_scene = get_tree().get_current_scene()
		var player = current_scene.get_node_or_null("Player")  # Ajusta si tu Player está en otro nodo
		if player and player.has_method("save_player_data"):
			player.save_player_data()

		get_tree().change_scene_to_file(STAGE_PATHS[zona])
