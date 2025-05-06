extends CanvasLayer

var pending_text := ""

@onready var label = $Panel/Label

func _ready():
	if label and pending_text != "":
		label.text = pending_text

	await get_tree().create_timer(3.0).timeout
	queue_free()

func set_text(new_text: String) -> void:
	pending_text = new_text
	if label:
		label.text = new_text
