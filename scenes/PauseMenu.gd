extends CanvasLayer

@onready var resume_btn = $Panel/VBoxContainer/ResumeButton
@onready var restart_btn = $Panel/VBoxContainer/RestartButton
@onready var main_menu_btn = $Panel/VBoxContainer/MainMenuButton
@onready var options_btn = $Panel/VBoxContainer/OptionsButton  # Asegúrate de tener este nodo
@onready var save_btn = $Panel/VBoxContainer/SaveButton
@onready var save_menu_scene := preload("res://scenes/save_menu.tscn")
@onready var options_scene := preload("res://scenes/options_menu.tscn")

var options_instance: Node = null
var save_menu_instance: Node = null
var enabled := false



func _ready():
	print("🟢 PauseMenu _ready ejecutado")
	visible = false
	get_tree().paused = false

	resume_btn.pressed.connect(_on_resume_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)
	main_menu_btn.pressed.connect(_on_main_menu_pressed)
	options_btn.pressed.connect(_on_options_pressed)
	save_btn.pressed.connect(_on_save_pressed)


func _input(event):
	if not enabled:
		return
	if event.is_action_pressed("pause_menu"):
		# 🔒 Si el menú de opciones está abierto, no hacer nada
		if options_instance and options_instance.visible:
			print("🚫 ESC ignorado: opciones abiertas")
			return

		print("🟨 ESC detectado")
		if visible:
			_on_resume_pressed()
		else:
			toggle()


func toggle():
	visible = not visible
	get_tree().paused = visible
	print("🔁 Menú de pausa visible:", visible)

func _on_resume_pressed():
	print("▶️ Reanudar")
	toggle()

func _on_restart_pressed():
	print("🔄 Reiniciar")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	print("🏠 Ir al menú principal")
	get_tree().paused = false
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_options_pressed():
	print("⚙️ Opciones")
	if not options_instance:
		options_instance = options_scene.instantiate()
		add_child(options_instance)
		options_instance.connect("cerrar_opciones", Callable(self, "_on_options_closed"))
	else:
		options_instance.visible = true

	visible = false  # Oculta el menú de pausa mientras se ve el de opciones

func _on_options_closed():
	print("🔙 Cerrado menú de opciones, volver a mostrar pausa")
	visible = true
	
func _on_save_pressed():
	print("💾 Guardar Partida")
	if not save_menu_instance:
		save_menu_instance = save_menu_scene.instantiate()
		add_child(save_menu_instance)
		save_menu_instance.connect("cerrar_menu_guardado", Callable(self, "_on_save_menu_closed"))
	else:
		save_menu_instance.visible = true

	visible = false  # Oculta menú de pausa

func _on_save_menu_closed():
	print("🔙 Cerrar menú guardado, volver a pausa")
	visible = true
