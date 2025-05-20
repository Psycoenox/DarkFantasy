extends Node2D

@onready var boss = $Boss  # Asegúrate de que tu nodo se llama así
@onready var bonfire_scene = preload("res://scenes/bonfire.tscn")  # Ajusta la ruta si es distinta

var npcs_hablados := 0
const NPCS_REQUERIDOS := 2 # Los dos NPCS del stage

func _ready():
	if boss:
		boss.connect("boss_defeated", Callable(self, "_on_boss_defeated"))
	else:
		print("❌ No se encontró el boss en la escena")

func registrar_npc_hablado():
	npcs_hablados += 1
	if npcs_hablados >= NPCS_REQUERIDOS:
		GameManager.missions["zona_1_npcs_hablados"] = true  # ✅ Marca misión como completada
		print("✅ Misión completada: Zona 2 desbloqueada.")

		
func _on_boss_defeated():
	print("🔥 El boss fue derrotado. Aparece la fogata.")

	var bonfire = bonfire_scene.instantiate()
	bonfire.global_position = boss.global_position + Vector2(0, -16)  # ajusta la posición si hace falta
	add_child(bonfire)
