extends CanvasLayer

@onready var label = $Panel/Label
@onready var player = get_tree().get_root().get_node("Stage1/Player") # o usa get_parent().get_node("Player") si aplica

var messages: Array = []
var index: int = 0
var auto_close_time := 0.0

func set_text_array(new_messages: Array, close_after: float = 3.0) -> void:
	messages = new_messages
	index = 0
	auto_close_time = close_after
	_show_current()

	if auto_close_time > 0:
		await get_tree().create_timer(auto_close_time).timeout
		if is_inside_tree():
			queue_free()

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
