extends CanvasLayer

@onready var sprite = $AnimatedSprite2D
@onready var boton_salir := $Salir
@onready var boton_mejorar := $Mejorar
@onready var boton_descansar := $Descansar

var ready_to_click := false  # 👈 Añadimos esta variable

func _ready():
	sprite.play("idle")
	await get_tree().create_timer(0.2).timeout  # espera 0.2 segundos
	boton_salir.grab_focus()
	ready_to_click = true  # ✅ solo después de 0.2s permitimos click

func _on_salir_pressed() -> void:
	if not ready_to_click:
		return  # ❌ ignora clicks que vengan demasiado pronto

	var player = get_tree().get_root().get_node("Stage1/Player")
	if player:
		player.set_can_move(true)

	queue_free()
