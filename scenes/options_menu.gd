extends CanvasLayer
signal cerrar_opciones

@onready var music_slider := $Panel/VBoxContainer/HBoxContainer/MusicSlider
@onready var sfx_slider := $Panel/VBoxContainer/HBoxContainer2/SFXSlider
@onready var back_button := $Panel/VBoxContainer/BackButton

func _ready():
	# Inicializa sliders con el valor actual de los buses reales
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))  # ✅ Ahora usa el bus SFX real

	# Conecta eventos
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	back_button.pressed.connect(_on_back_button_pressed)

func _on_music_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)

func _on_sfx_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)  # ✅ Ahora controla SFX

func _on_back_button_pressed() -> void:
	visible = false
	emit_signal("cerrar_opciones")
