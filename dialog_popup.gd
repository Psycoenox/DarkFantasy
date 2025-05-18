extends CanvasLayer

@onready var label = $Panel/Label

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
