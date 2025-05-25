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
	_update_boton_texto(button_zona1, "Zona 1", GameManager.desbloquear_zona("1"))
	_update_boton_texto(button_zona2, "Zona 2", GameManager.desbloquear_zona("2"))
	_update_boton_texto(button_zona3, "Zona 3", GameManager.desbloquear_zona("3"))
	_update_boton_texto(button_zona4, "Zona Final", GameManager.desbloquear_zona("4"))

func _update_boton_texto(button: Button, nombre: String, desbloqueado: bool):
	if desbloqueado:
		button.text = nombre
	else:
		button.text = nombre + " (Bloqueado)"

func _input(event):
	if event.is_action_pressed("open_map"):
		visible = not visible
		if visible:
			update_buttons()
		else:
			emit_signal("mapa_cerrado")  # ✅ Esto reactiva el movimiento del jugador

func _show_bloqueado_popup():
	var dialog_scene = preload("res://scenes/dialog_popup.tscn")
	var dialog = dialog_scene.instantiate()
	get_tree().get_root().add_child(dialog)
	
	dialog.set_text_array(["🚫 No tienes acceso todavía a esta región."], 3.0)



func _ir_a_zona(zona: String) -> void:
	print("🧭 Intentando ir a:", zona)
	if not GameManager.desbloquear_zona(zona.substr(4, 1)):  # zona1 -> "1"
		_show_bloqueado_popup()
		return

	if STAGE_PATHS.has(zona):
		visible = false
		emit_signal("mapa_cerrado")

		var current_scene = get_tree().get_current_scene()
		var player = current_scene.get_node_or_null("Player")
		if player and player.has_method("save_player_data"):
			player.save_player_data()

		await get_tree().create_timer(0.2).timeout  # pequeño delay opcional
		get_tree().change_scene_to_file(STAGE_PATHS[zona])
