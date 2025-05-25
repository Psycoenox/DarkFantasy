extends CanvasLayer

@onready var btn_health := $Panel/MejorarVida
@onready var btn_damage := $Panel/MejorarDaño
@onready var btn_exit := $Panel/Salir
@onready var label := $Panel/Mejoras


var player: Node = null
var upgrade_cost := 5

func _ready():
	btn_health.pressed.connect(_on_health_pressed)
	btn_damage.pressed.connect(_on_damage_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	print("📦 PlayerData cargado:", PlayerData)

func _on_health_pressed():
	if player and player.coins >= upgrade_cost:
		player.coins -= upgrade_cost
		PlayerData.coins = player.coins  # ✅ ACTUALIZAR COINS PERSISTENTE
		player.max_health += 10
		player.health = player.max_health
		PlayerData.upgrades.health_lvl += 1  # ⬅️ PERSISTE la mejora
		player.stats_updated.emit()
		player.monedas_actualizadas.emit(player.coins)
		label.text = "✔️ Vida mejorada +10"
	else:
		label.text = "❌ Monedas insuficientes"

func _on_damage_pressed():
	if player and player.coins >= upgrade_cost:
		player.coins -= upgrade_cost
		PlayerData.coins = player.coins  # ✅ ACTUALIZAR COINS PERSISTENTE

		player.base_attack_damage += 5
		player.monedas_actualizadas.emit(player.coins)
		PlayerData.upgrades.damage_lvl += 1  # ⬅️ PERSISTE la mejora
		label.text = "✔️ Daño mejorado +5"
	else:
		label.text = "❌ Monedas insuficientes"

func _on_exit_pressed():
	queue_free()
	if player:
		player.set_can_move(true)
