extends CanvasLayer

@onready var boss_bar: TextureProgressBar = $Control/BossHealthBar

# Inicializa la barra de vida
func setup(max_health: int):
	boss_bar.max_value = max_health
	boss_bar.value = max_health
	show()

# Actualiza el valor de vida
func update_health(current_health: int):
	boss_bar.value = clamp(current_health, 0, boss_bar.max_value)

# Oculta la barra de vida (al morir, por ejemplo)
func hide_bar():
	hide()
