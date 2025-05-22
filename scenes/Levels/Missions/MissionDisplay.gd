extends CanvasLayer

@onready var progress_label := $VBoxContainer/ProgressLabel
@onready var animation_player := $AnimationPlayer

var total_npcs := 2
var talked_to := 0
var mission_activa := false

func activar_mision(total: int):
	talked_to = 0
	total_npcs = total
	mission_activa = true
	progress_label.visible = true
	progress_label.modulate.a = 1.0  # Reinicia opacidad por si acaso
	actualizar_progreso()

func actualizar_progreso():
	if not mission_activa:
		return

	progress_label.text = "Misión: Hablar con todos los NPCs (%d/%d)" % [talked_to, total_npcs]

	if talked_to >= total_npcs:
		GameManager.missions["zona_1_npcs_hablados"] = true
		mission_activa = false
		print("✅ Misión completada")

		# 👇 Deja visible el texto un momento y luego desvanece
		animation_player.play("fade_out_progress")

func registrar_npc():
	if mission_activa:
		talked_to += 1
		actualizar_progreso()
