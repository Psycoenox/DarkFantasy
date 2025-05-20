extends CanvasLayer

@onready var label = $Panel/Label
@onready var player = get_tree().get_root().get_node("Stage1/Player") # o usa get_parent().get_node("Player") si aplica

var messages: Array = []
var index: int = 0

func set_text_array(new_messages: Array) -> void:
	messages = new_messages
	index = 0
	_show_current()

func advance_text():
	index += 1
	_show_current()

func _show_current():
	if index < messages.size():
		label.text = messages[index]
	else:
		queue_free()
		
func _on_upgrade_health_pressed():
	if player and player.has_method("upgrade_health"):
		player.upgrade_health(20)  # 🔧 Mejora en +20 vida
